######################################################################################################################################################
#
# Created: 01/20/2016  by Adam Fowler, EMC Implementation Delivery Specialist Central Division
# Modified:
# 
#
# ps_isilon_add_root_clients_to_all_exports_via_papi.ps1 - Sets root clients for all NFS exports / Should keep existing root-clients and add root clients defined
#
# Note: You need to be at OneFS 7.2.0 or greater to leverage the PAPI and HTTP Access must be enabled on the cluster.
#
# PARAMETERS
#
# -isilonip = node IP
# -username
# -password
# -rootclients
#
# EXAMPLE
# .\ps_isilon_add_root_clients_to_all_exports_via_papi.ps1  -isilonip 10.10.10.1 -user root -password P@ssword1 -rootclients 10.10.1.54
# 
# 
########################################################################################################################################


#########################
#                       #
# ACCEPTABLE PARAMETERS #
#                       #
#########################
Param([String]$isilonip,[String]$username,[String]$password,[Array]$rootclients)


######################################################
# Avoid certificate error (code from blogs.msdn.com) #
######################################################
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

###########################################################################
# Encode basic authorization header and create baseurl for Source Cluster #
###########################################################################
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $isilonip +":8080"

#####################################################################
# if the correct parameters were not passed we exit after a message #
#####################################################################
if (!($isilonip -and $username -and $password )) {
   write "failed to specify parameters";
   write ".\ps_isilon_create_nfs_export_via_papi.ps1  -isilonip 10.10.10.1 -user root -password P@ssword1" ;
   exit
}

###################################################
#                                                 #
#                                                 #
#    Get full list of all existing NFS exports    #
#                                                 #
#                                                 #
###################################################
$resourceurl = "/platform/2/protocols/nfs/exports"
$uri = $baseurl + $resourceurl
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

# Loop through each export
ForEach($export in $ISIObject.exports) {
$export_id = $export.id
$export_rootclients = $export.root_clients 
Write-Host "'Export ID: " $export_id -Background Cyan

# Add root clients
$ExportObject = @"
{"root_clients":["$export_rootclients","$rootclients"]}
"@

Write-Host "--> Adding $rootclients as root client(s) to the above Export ID"
$resourceurl = "/platform/2/protocols/nfs/exports/$export_id"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resourceurl
$ISIObject2 = Invoke-RestMethod -Uri $uri -Headers $headers -Body $ExportObject -ContentType "application/json; charset=utf-8" -Method PUT
Write-Host "-->Done!"
}