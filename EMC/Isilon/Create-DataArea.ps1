#########################################################################################################################################
#                                                                                                                                       #
# Created:  02/19/2016  by Adam Fowler, EMC Implementation Delivery Specialist II Central Division                                      #
#                                                                                                                                       #
# Customer: Eli Lilly                                                                                                                   #
# Purpose:  Standardized Directory Creation for NAS Data Area on the Isilon                                                             #
#                                                                                                                                       #
# Comments: Script creates directory beneath Share Path defined by Administrator, removes all Inheritance ACL's and sets                #
#           new permissions based user input of groups (permitting modify or read on those groups).                                     #
#                                                                                                                                       #
# Note:     You need to be at OneFS 7.0.2 or greater to leverage the PAPI and HTTP Access must be enabled on the cluster.               #
#                                                                                                                                       #
#########################################################################################################################################

##########################
# Purge stored variables #
##########################
Remove-Variable * -ErrorAction SilentlyContinue
#############################################
# CertificatePolicy = TrustAll Certificates #
#############################################
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
########################
# functions for script #
########################
function 1_DataAreaInput {
$ritm = Read-Host -Prompt 'Provide RITM'
$clustername = Read-Host -Prompt 'Provide Isilon Cluster Name'
$smartconnect = Read-Host -Prompt 'Enter SmartConnect Zone Name in System Zone'
$Getcred = Get-Credential -Message 'Enter Root Credentials'
$password = $Getcred.GetNetworkCredential().Password
$username = $Getcred.UserName
$data_area = Read-Host -Prompt 'Provide Data Area Name'
$clusterpath = Read-Host -Prompt 'Provide Full Path to Data Area [i.e. /ifs/indyfiler01/backup/PURDUE]'
$fullclusterpath = $clusterpath + "/" + $data_area
$size = Read-Host -Prompt 'Provide Directory Quota Size (in GB) [i.e. 100 would indicate 100GB]'
Do
{
$group = Read-Host -Prompt 'Provide Active Directory Group for Access [domain\\group | am\\somgroup]'
$permission = Read-Host -Prompt "Provide permission to grant $group (modify or read)"
$loop = Read-Host -Prompt 'Add another Group? (y/n)'
If (!$global:grouptable) {$global:grouptable += @{ $group = "$permission"}}
Else {$global:grouptable.Add("$group","$permission")}
}
Until ($loop -eq 'n' -or $loop -eq 'no')
2_CheckInput }
function 2_CheckInput {
Clear-Host
Echo $date | Tee-Object -Append $env:TEMP\$ritm
Echo "----------------------------------------------------------------" | Tee-Object -Append $env:TEMP\$ritm
Echo "User Performing Script:" $PSuser | Tee-Object -Append $env:TEMP\$ritm
Echo "RITM: $ritm" | Tee-Object -Append $env:TEMP\$ritm
Echo "Cluster Name: $clustername" | Out-File $env:TEMP\$ritm
Echo "Account executing request: $username" | Tee-Object -Append $env:TEMP\$ritm
Echo "" | Tee-Object -Append $env:TEMP\$ritm
Echo "Script will perform the following actions:" | Tee-Object -Append $env:TEMP\$ritm
Echo "Data Area Name to be created: $data_area" | Tee-Object -Append $env:TEMP\$ritm
Echo "Creating new directory path: $fullclusterpath" | Tee-Object -Append $env:TEMP\$ritm
Echo "Quota on $fullclusterpath : $size GB" | Tee-Object -Append $env:TEMP\$ritm
Echo "::Permission Being Set on $fullclusterpath::" | Tee-Object -Append $env:TEMP\$ritm
Echo $grouptable | Tee-Object -Append $env:TEMP\$ritm
Echo "----------------------------------------------------------------" | Tee-Object -Append $env:TEMP\$ritm
$continue = Read-Host -Prompt 'Continue? y/n'
If ($continue -eq 'y') {3_Execute}
ElseIf ($continue -eq 'yes') {3_Execute}
Else {Write-Host "Stopping Script! No changes have been made to the cluster! Have a nice day!"}
Read-Host -Prompt "Press Enter to exit"}
function 3_Execute {
########################################################
# Encode basic authorization header and create baseurl #
########################################################
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
$namespace = $fullclusterpath
#################################################
# 1. Create Data Area based on $fullclusterpath #
#################################################
$uriMKDIR = $baseurl + "/namespace" + $fullclusterpath
$existence = $baseurl + "/namespace" + $fullclusterpath + "?metadata"
$mkdir_header = @{"Authorization"="Basic $($EncodedPassword)";"x-isi-ifs-target-type"="container"}
$ErrorActionPreference = "SilentlyContinue"
$ConfirmDirectoryExistence = Invoke-RestMethod -Uri $existence -Headers $mkdir_header -Method GET
$ErrorActionPreference = "Continue"
If (!$ConfirmDirectoryExistence.attrs) 
{
$ISIObjectMKDIR = Invoke-RestMethod -Uri $uriMKDIR -Headers $mkdir_header -Method PUT
Write-Host "Creating Directory..."
Start-Sleep -s 2
Write-Host "Modifying ACLs..."
########################################################################
# 2. Set Permissions on recently created data area based on user input #
########################################################################
$purgeACLs = @"
{
"authoritative":"acl",
"action":"replace",
"acl":[]
}
"@
$resourceurlACL = "/namespace" + $fullclusterpath + "?acl&nsaccess"
$uriACL = $baseurl + $resourceurlACL
$ISIObjectPURGE = Invoke-RestMethod -Uri $uriACL -Headers $headers -Body $purgeACLs -Method PUT
#######################
#Loop through $groups #
#######################
ForEach ($a in $grouptable.Keys.GetEnumerator())
{
$aclBodyModify = @"
{
"authoritative":"acl",
"action":"update",
"acl":[
{
"trustee":{
"name":"$a",
"type":"group"
},
"accesstype":"allow",
"accessrights":[
"dir_gen_read", "dir_gen_write", "dir_gen_execute", "delete_child"
],
"inherit_flags":[
"object_inherit", "container_inherit"
],
"op":"add"
}
]
}
"@
$aclBodyRead = @"
{
"authoritative":"acl",
"action":"update",
"acl":[
{
"trustee":{
"name":"$a",
"type":"group"
},
"accesstype":"allow",
"accessrights":[
"dir_gen_read", "dir_gen_read", "dir_gen_execute"
],
"inherit_flags":[
"object_inherit", "container_inherit"
],
"op":"add"
}
]
}
"@
switch ($grouptable.$a)
    {
    "read" {Invoke-RestMethod -Uri $uriACL -Headers $headers -Body $aclBodyRead -Method PUT}
    "modify" {Invoke-RestMethod -Uri $uriACL -Headers $headers -Body $aclBodyModify -Method PUT}
    }
}
#####################################################################
# 3. Create Quota on recently created data area based on user input #
#####################################################################
Start-Sleep -s 2
Write-Host "Creating Quota..."
$resourceurlQuota = "/platform/1/quota/quotas"
$uriQuota = $baseurl + $resourceurlQuota
$quotasize = ([Int64]$size * 1GB)
$QuotaObjectBody = @"
{"type":"directory","include_snapshots": false,"container": true, "path": "$namespace", "enforced": true, "thresholds": {"hard":$quotasize},"thresholds_include_overhead": false}
"@
$ISIObject = Invoke-RestMethod -Uri $uriQuota -Headers $headers -Body $QuotaObjectBody -ContentType "application/json; charset=utf-8" -Method POST
$QuotaID = $ISIObject.id
Start-Sleep -s 2
Write-Host "Finished"
Write-Host ""
######################################
# 4. Get and Validate Script Actions #
######################################
Start-Sleep -s 2
Echo "Validating Script Execution for $RITM" | Tee-Object -Append $env:TEMP\$ritm
Echo "Directory Created: $fullclusterpath" | Tee-Object -Append $env:TEMP\$ritm
Echo "" | Tee-Object -Append $env:TEMP\$ritm
Start-Sleep -s 2
# Quota Confirm 
Echo "Quota Validation" | Tee-Object -Append $env:TEMP\$ritm
$QuotaGet = $baseurl + $resourceurlQuota + "/" + $QuotaID
$ISIQuotaGET = Invoke-RestMethod -Uri $QuotaGet -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
$ISIQuotaGET.quotas | Tee-Object -Append $env:TEMP\$ritm
# Data Area Directory and Permission Confirm 
Start-Sleep -s 2
Echo "" | Tee-Object -Append $env:TEMP\$ritm
Echo "Data Area Directory and Permissions Validation" | Tee-Object -Append $env:TEMP\$ritm
$ContainerGET = $baseurl + "/namespace" + $fullclusterpath + "?acl=true"
$ISIContainerGET = Invoke-RestMethod -Uri $ContainerGet -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
$ISIContainerGET.acl | Tee-Object -Append $env:TEMP\$ritm 
Copy-Item $env:TEMP\$ritm -Destination \\$smartconnect\ifs\data\
Echo "Local Log File $env:TEMP\$ritm"
Read-Host -Prompt "Press Enter to exit"
}
ElseIf ($ConfirmDirectoryExistence.attrs)
{Write-Warning "Stopping script immediately. Directory already exists. If you feel you've met this error by mistake, contact your NAS Administrator."  | Tee-Object -Append $env:TEMP\$ritm 
Read-Host -Prompt "Press Enter to exit"}
}
####################################
#  Accept General Warning Message  #
####################################
$date = Get-Date
$PSuser = $env:USERDOMAIN + "\" + $env:USERNAME
Write-Warning "You are about to execute a OneFS script for Data Area Creation."
Write-Warning "You must have a RITM or Change before executing."
Write-Warning "Data Area Creation runs as the root user on the Isilon cluster."
Write-Host "INFO: Paths and Data Area names ARE case sensitive"
Start-Sleep -s 1
$ProcedureWarning = Read-Host -Prompt "Do you want to proceed? (y/n)"
If ($ProcedureWarning -eq 'y') {1_DataAreaInput}
ElseIf ($ProcedureWarning -eq 'yes') {1_DataAreaInput}
Else {Write-Host "Okay! Have a nice day!"
Read-Host -Prompt "Press Enter to exit"}