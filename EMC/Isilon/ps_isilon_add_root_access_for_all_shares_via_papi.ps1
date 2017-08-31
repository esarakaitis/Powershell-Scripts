######################################################################################################################################################
#
# Created: 01/22/2016  by Adam Fowler, EMC Implementation Delivery Specialist II Central Division
# Modified:
# 
#
# ps_isilon_add_root_access_to_all_shares_via_papi.ps1 - Add run-as-root privileges to all shares for administrator/migration account 
# Note: You need to be at OneFS 7.0.2 or greater to leverage the PAPI and HTTP Access must be enabled on the cluster.
#
# PARAMETERS
#
# -isilonip = node IP
# -username
# -password
# -account = account to provide run-as-root privileges for all shares
#
# EXAMPLE
# .\ps_isilon_add_root_access_to_all_shares_via_papi.ps1  -isilonip 10.10.10.1 -user root -password P@ssword1 -account emctest\\svc_migration
# 
# 
########################################################################################################################################

# Accept input parameters
Param([String]$isilonip,[String]$username,[String]$password,[String]$account)


# With a default cert you would normally see a cert error (code from blogs.msdn.com)
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
 
    public class TrustAll : ICertificatePolicy {
    public TrustAll() {}
    public bool CheckValidationResult(
        ServicePoint sPoint, X509Certificate cert,
        WebRequest req, int problem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = new-object TrustAll



#if the correct parameters were not passed we exit after a message
if (!($isilonip -and $username -and $password )) {
   write "failed to specify parameters";
   write ".\ps_isilon_add_root_access_to_all_shares_via_papi.ps1  -isilonip 10.10.10.1 -user root -password P@ssword1 -account emctest\\svc_migration " ;
   exit
}
 
 
# Encode basic authorization header and create baseurl
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $isilonip +":8080"

# Get all defined shares           
$resourceurl = "/platform/1/protocols/smb/shares"
$uri = $baseurl + $resourceurl
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
# Loop through each share
ForEach($share in $ISIObject.shares) 
{
$share_name = $share.name
Write-Host "Share Name: "  $share_name -background Green
 
#create run-as-root permission
$RunAsRootObject = @"
{"run_as_root": [{"name":"$account","type":"user"}]}
"@ 
Write-Host "--> Changing share permissions to" $RunAsRootObject
$resourceurl = "/platform/1/protocols/smb/shares/$share_name"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resourceurl
$ISIObject2 = Invoke-RestMethod -Uri $uri -Headers $headers -Body $RunAsRootObject -ContentType "application/json; charset=utf-8" -Method PUT
Write-Host "-->Done!"
}