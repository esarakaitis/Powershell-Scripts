#########################################################################################################################################
#                                                                                                                                       #
# Created:  03/03/2016  by Adam Fowler, EMC Implementation Delivery Specialist II Central Division                                      #
#                                                                                                                                       #
# Customer: Eli Lilly                                                                                                                   #
# Purpose:  Snapshots Menu for Isilon Cluster                                                                                           #
#                                                                                                                                       #
# Comments: List Snapshots, List Snaps pending delete, List Snap Schedules, Recover Directories/Files, Create & Delete Snapshots        #
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

#############
# Functions #
#############
function menu {
Write-Host "###############################"
Write-Host "#                             #"
Write-Host "# OneFS Snapshot Options Menu #"
Write-Host "#         Version 1.0         #"
Write-Host "#                             #"
Write-Host "###############################"
Write-Host ""
Write-Host "1. List Snapshots"
Write-Host "2. List Snapshots Pending Deletion"
Write-Host "3. List Snapshot Schedules"
Write-Host "4. Recover a directory from Snapshots"
Write-Host "5. Recover a file from Snapshots"
Write-Host "6. Delete a Snapshot"
Write-Host "7. Create a Snapshot"
Write-Host "8. Exit Menu"
Write-Host ""
$selection = Read-Host -Prompt "Enter selection: "
#switch
switch ($selection)
{
1 { ListSnaps }
2 { ListSnapsToBeDeleted }
3 { ListSchedules }
4 { RecoverDir }
5 { RecoverFile }
6 { DeleteSnap }
7 { CreateSnapshot }
8 { Snap_Exit }
default {Write-Host "Please make a valid selection from the list"}
}
}
function ListSnaps {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$resource="/platform/1/snapshot/snapshots/"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
$ListSnaps = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
$ListSnaps.snapshots
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
function ListSnapsToBeDeleted {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$resource="/platform/1/snapshot/snapshots?type=deleting"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
$ListSnaps = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
function ListSchedules {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$resource="/platform/1/snapshot/schedules/"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
$ListSchedules = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
$ListSchedules.schedules
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
function RecoverDir {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
Write-Host "1. Recover In-Place"
Write-Host "2. Recover Elsewhere"
$recover_options = Read-Host -Prompt "Enter Selection"
switch ($recover_options)
{
1 {
$recover_dir = Read-Host -Prompt "Provide name of directory to restore"
$parent = Read-Host -Prompt "Provide full parent path where directory resides"
$snapshot = Read-Host -Prompt "Provide the verbatm snapshot name to restore From"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers1 = @{"Authorization"="Basic $($EncodedPassword)";"x-isi-ifs-copy-source"="/namespace" + $parent + "/.snapshot/" + $snapshot + "/" + $recover_dir}
$baseurl = 'https://' + $smartconnect +":8080"
$uri1 = $baseurl + "/namespace" + $parent + "/" + $recover_dir + "/?merge=true&continue=true"
$snapshotrecovery = Invoke-RestMethod -Uri $uri1 -Headers $headers1 -Method PUT
Write-Host "Restore of $recover_dir in $parent Successful"
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
2 {
$recover_dir = Read-Host -Prompt "Provide name of directory to restore"
$parent = Read-Host -Prompt "Provide full parent path where directory resides"
$newpath = Read-Host -Prompt "Provide path where you want the data restored to"
$snapshot = Read-Host -Prompt "Provide the verbatm snapshot name to restore From"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers2 = @{"Authorization"="Basic $($EncodedPassword)";"x-isi-ifs-copy-source"="/namespace" + $parent + "/.snapshot/" + $snapshot + "/" + $recover_dir}
$baseurl = 'https://' + $smartconnect +":8080"
$uri2 = $baseurl + "/namespace" + $newpath + "/?merge=true&continue=true"
$snapshotrecovery = Invoke-RestMethod -Uri $uri2 -Headers $headers2 -Method PUT
Write-Host "Restore of $recover_dir in $parent Successfully restored to $newpath"
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
default {
Write-Host "Please make a valid selection from the list"}
}

}
function RecoverFile {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
Write-Host "1. Restore - Overwrite MyFile"
Write-Host "2. Restore - MyFile_copy"
$recover_options = Read-Host -Prompt "Enter Selection"
switch ($recover_options)
{
1 {
$parent = Read-Host -Prompt "Provide full path where file resides"
$recover_file = Read-Host -Prompt "Provide name of file to restore"
$snapshot = Read-Host -Prompt "Provide the verbatm snapshot name to restore From"
$headers1 = @{"Authorization"="Basic $($EncodedPassword)";"x-isi-ifs-copy-source"="/namespace" + $parent + "/.snapshot/" + $snapshot + "/" + $recover_file}
$baseurl = 'https://' + $smartconnect +":8080"
$uri1 = $baseurl + "/namespace" + $parent + "/" + $recover_file
$snapshotrecovery = Invoke-RestMethod -Uri $uri1 -Headers $headers1 -Method PUT
Write-Host "Restore of $recover_file in $parent Successful"
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
2 {
$parent = Read-Host -Prompt "Provide full path where file resides"
$recover_file = Read-Host -Prompt "Provide name of file to restore"
$recover_newname = $recover_file + "_copy"
$snapshot = Read-Host -Prompt "Provide the verbatm snapshot name to restore From"
$headers1 = @{"Authorization"="Basic $($EncodedPassword)";"x-isi-ifs-copy-source"="/namespace" + $parent + "/.snapshot/" + $snapshot + "/" + $recover_file}
$baseurl = 'https://' + $smartconnect +":8080"
$uri1 = $baseurl + "/namespace" + $parent + "/" + $recover_newname
$snapshotrecovery = Invoke-RestMethod -Uri $uri1 -Headers $headers1 -Method PUT
Write-Host "Restore of $recover_file in $parent Successful"
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
default {
Write-Host "Please make a valid selection from the list"}
}
}
function DeleteSnap {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$resource="/platform/1/snapshot/snapshots/"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$snapshot = Read-Host -Prompt "Provide name of Snapshot you'd like to delete"
$uri = $baseurl + $resource + $snapshot
If (!$snapshot) {
Write-Host "Invalid Input. Must Enter a Snapshot Name"
menu}
Else {
$deleteproceed = Read-Host -Prompt "Are you sure you'd like to delete the snapshot named $snapshot ? (y/n)"
If ($deleteproceed -eq 'y' -or 'yes')
{ 
Invoke-RestMethod -Uri $uri -Headers $headers -Method DELETE
Write-Host ""
Write-Host ""
Write-Host ""
menu}
Else {
Write-Host ""
Write-Host ""
Write-Host ""
menu}
}
}
function CreateSnapshot {
$smartconnect = Read-Host -Prompt "Provide SmartConnect Zone Name for Cluster"
$Getcred = Get-Credential -Message 'Enter Credentials for Authentication to Cluster'
$username = $Getcred.UserName
$password = $Getcred.GetNetworkCredential().Password
$resource="/platform/1/snapshot/snapshots/"
$EncodedAuthorization = [System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password)
$EncodedPassword = [System.Convert]::ToBase64String($EncodedAuthorization)
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$baseurl = 'https://' + $smartconnect +":8080"
$uri = $baseurl + $resource
$snapname = Read-Host -Prompt "Provide Snapshot Name"
$snappath = Read-Host -Prompt "Provide Path to Snap"
$snapshotbody = @"
{"name" : "$snapname", "path" : "$snappath"}
"@
$CreateSnapshot = Invoke-RestMethod -Uri $uri -Body $snapshotbody -Headers $headers -Method POST
Write-Host ""
Write-Host ""
Write-Host ""
menu
}
function Snap_Exit {}

#########
# Begin #
#########
Write-Host "Greetings, $env:Username !"
Write-Host ""
menu