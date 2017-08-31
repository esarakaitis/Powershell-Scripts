#########################################################################################################################################
#                                                                                                                                       #
# Created:  03/05/2016  by Adam Fowler, EMC Implementation Delivery Specialist II Central Division                                      #
#                                                                                                                                       #
# Customer: Eli Lilly                                                                                                                   #
# Purpose: Menu for All Things Isilon via API                                                                                           #
#                                                                                                                                       #
# Comments:                                                                                                                             #
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
#Snapshots
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
Write-Host "##########################"
Write-Host "SnapShots on $smartconnect"
Write-Host "##########################"
$ListSnaps.snapshots
Write-Host "Total Number of Snapshots:"
$ListSnaps.total
Write-Host ""
Write-Host ""
Write-Host ""
SnapshotsMenu
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
$ListDeletedSnaps = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
Write-Host "###########################################"
Write-Host "SnapShots Pending Deletion on $smartconnect"
Write-Host "###########################################"
$ListDeletedSnaps.snapshots
Write-Host ""
Write-Host ""
Write-Host ""
SnapshotsMenu
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
SnapshotsMenu
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
SnapshotsMenu
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
SnapshotsMenu
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
SnapshotsMenu
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
SnapshotsMenu
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
SnapshotsMenu}
Else {
$deleteproceed = Read-Host -Prompt "Are you sure you'd like to delete the snapshot named $snapshot ? (y/n)"
If ($deleteproceed -eq 'y' -or 'yes')
{ 
Invoke-RestMethod -Uri $uri -Headers $headers -Method DELETE
Write-Host ""
Write-Host ""
Write-Host ""
SnapshotsMenu}
Else {
Write-Host ""
Write-Host ""
Write-Host ""
SnapshotsMenu}
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
SnapshotsMenu
}
function Snap_Exit {
Clear-Host
MainMenu
}
function SnapshotsMenu {
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
$Snapselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Snapselection)
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
#SMB Shares
function ListShares {

}
function CreateShare {

}
function DeleteShare {

}
function ModifySharePermission {

}
function RemoveSharePermission {

}
function Share_Exit {
Clear-Host
MainMenu
}
function SMBShare_Menu {
Write-Host "#################################"
Write-Host "#                               #"
Write-Host "# OneFS SMB Shares Options Menu #"
Write-Host "#         Version 1.0           #"
Write-Host "#                               #"
Write-Host "#################################"
Write-Host ""
Write-Host "1. List SMB Shares"
Write-Host "2. Create SMB Share"
Write-Host "3. Delete SMB Share"
Write-Host "4. Modify Share Permission"
Write-Host "5. Remove Share Permission"
Write-Host "6. Exit Menu"
Write-Host ""
$selection = Read-Host -Prompt "Enter selection: "
#switch
switch ($selection)
{
1 { ListShares }
2 { CreateShare }
3 { DeleteShare }
4 { ModifySharePermission }
5 { RemoveSharePermission }
6 { Share_Exit }
default {Write-Host "Please make a valid selection from the list"}
}
}
#NFS Exports
function ListNFSExports {

}
function CreateNFSExport {

}
function ModifyExistingNFSExport {

}
function DeleteNFSExport {

}
function Export_Exit {
Clear-Host
MainMenu
}
function NFSExport_Menu {
Write-Host "#################################"
Write-Host "#                               #"
Write-Host "# OneFS NFS Export Options Menu #"
Write-Host "#         Version 1.0           #"
Write-Host "#                               #"
Write-Host "#################################"
Write-Host ""
Write-Host "1. List NFS Exports"
Write-Host "2. Create NFS Export"
Write-Host "3. Modify Existing NFS Export"
Write-Host "4. Delete NFS Export"
Write-Host "5. Exit Menu"
Write-Host ""
$NFSselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($NFSselection)
{
1 { ListNFSExports }
2 { CreateNFSExport }
3 { ModifyExistingNFSExport }
4 { DeleteNFSExport }
5 { Export_Exit }

default {Write-Host "Please make a valid selection from the list"}
}
}
#SmartQuotas
function ListQuotas {

}
function CreateNewQuota {

}
function ModifyExistingQuota {

}
function DeleteQuota {

}
function Quotas_Exit {
Clear-Host
MainMenu
}
function SmartQuotas_Menu {
Write-Host "##################################"
Write-Host "#                                #"
Write-Host "# OneFS SmartQuotas Options Menu #"
Write-Host "#         Version 1.0            #"
Write-Host "#                                #"
Write-Host "##################################"
Write-Host ""
Write-Host "1. List Quotas"
Write-Host "2. Create New SmartQuotas"
Write-Host "3. Modify Existing SmartQuota"
Write-Host "4. Delete SmartQuota"
Write-Host "5. Exit Menu"
Write-Host ""
$Quotaselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Quotaselection)
{
1 { ListQuotas }
2 { CreateNewQuota }
3 { ModifyExistingQuota }
4 { DeleteQuota }
5 { Quotas_Exit }

default {Write-Host "Please make a valid selection from the list"}
}
}
#SyncIQ
function ListSyncIQJobs {
}
function ViewSyncIQJob {
}
function StartSyncIQJob {
}
function ModifySyncIQJob {
}
function DeleteSyncIQJob {
}
function SyncIQ_Exit {
Clear-Host
MainMenu
}
function SyncIQ_Menu {
Write-Host "#############################"
Write-Host "#                           #"
Write-Host "# OneFS SyncIQ Options Menu #"
Write-Host "#        Version 1.0        #"
Write-Host "#                           #"
Write-Host "#############################"
Write-Host ""
Write-Host "1. List SyncIQ Replication Jobs"
Write-Host "2. View Details of SyncIQ Replication Job"
Write-Host "3. Start Existing SyncIQ Replication Job"
Write-Host "4. Modify SyncIQ Replication Job"
Write-Host "5. Delete SyncIQ Replication Job"
Write-Host "6. Exit Menu "
Write-Host ""
$SyncIQselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($SyncIQselection)
{
1 { ListSyncIQJobs }
2 { ViewSyncIQJob }
3 { StartSyncIQJob }
4 { ModifySyncIQJob }
5 { DeleteSyncIQJob }
6 { SyncIQ_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#Auditing
function ListAuditSettings {

}
function ModifyAuditSettings {

}
function Audit_Exit {
Clear-Host
MainMenu
}
function Auditing_Menu {
Write-Host "############################"
Write-Host "#                          #"
Write-Host "# OneFS Audit Options Menu #"
Write-Host "#        Version 1.0       #"
Write-Host "#                          #"
Write-Host "############################"
Write-Host ""
Write-Host "1. List Audit Settings "
Write-Host "2. Modify Audit Settings"
Write-Host "3. Exit Menu "
Write-Host ""
$Auditselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Auditselection)
{
1 { ListAuditSettings }
2 { ModifyAuditSettings }
3 { Audit_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#System Jobs
function GetAllSystemJobTypes {
}
function ViewSystemJobDetails {
}
function ModifySystemJobType {
}
function GetAllJobImpactPolicies {
}
function ViewJobImpactPolicyDetails {
}
function CreateJobImpactPolicy {
}
function ModifyExistingJobImpactPolicy {
}
function DeleteJobImpactPolicy {
}
function SystemJobs_Exit {
Clear-Host
MainMenu
}
function SystemJobs_Menu {
Write-Host "##################################"
Write-Host "#                                #"
Write-Host "# OneFS System Jobs Options Menu #"
Write-Host "#           Version 1.0          #"
Write-Host "#                                #"
Write-Host "##################################"
Write-Host ""
Write-Host "1. Get All System Job Types"
Write-Host "2. View Details of Specific System Job"
Write-Host "3. Modify a System Job Type"
Write-Host "4. Get All Job Impact Policies"
Write-Host "5. View Details of Specific Job Impact Policy"
Write-Host "6. Create a Job Impact Policy"
Write-Host "7. Modify Existing Job Impact Policy"
Write-Host "8. Delete Job Impact Policy"
Write-Host "9. Exit Menu "
Write-Host ""
$SysJobselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($SysJobselection)
{
1 { GetAllSystemJobTypes }
2 { ViewSystemJobDetails }
3 { ModifySystemJobType }
4 { GetAllJobImpactPolicies }
5 { ViewJobImpactPolicyDetails }
6 { CreateJobImpactPolicy }
7 { ModifyExistingJobImpactPolicy }
8 { DeleteJobImpactPolicy }
9 { SystemJobs_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#DeDuplication
function ListDeDuplicationJobs {
}
function GetDeDuplicationJobSettings {
}
function ModifyDeDuplicationJobSettings {
}
function RunDeDuplicationReport {
}
function Dedupe_Exit {
Clear-Host
MainMenu
}
function DeDuplication_Menu {
Write-Host "####################################"
Write-Host "#                                  #"
Write-Host "# OneFS DeDuplication Options Menu #"
Write-Host "#           Version 1.0            #"
Write-Host "#                                  #"
Write-Host "####################################"
Write-Host ""
Write-Host "1. List De-Duplication Jobs"
Write-Host "2. Get De-Duplication Settings of Job"
Write-Host "3. Modify De-Duplication Settings of a Job"
Write-Host "4. Run De-Duplication Report"
Write-Host "5. Exit Menu"
Write-Host ""
$Auditselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Auditselection)
{
1 { ListAuditSettings }
2 { ModifyAuditSettings }
3 { Audit_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#FilePools
function ViewDefaultFilePoolPolicyInformation {
}
function ModifyDefaultFilePool {
}
function ListFilePoolPolicyTemplates {
}
function ViewFilePoolPolicyTemplateDetails {
}
function CreateFilePoolPolicy {
}
function ModifyExistingFilePoolPolicy {
}
function FilePool_Exit {
Clear-Host
MainMenu
}
function FilePools_Menu {
Write-Host "################################"
Write-Host "#                              #"
Write-Host "# OneFS FilePools Options Menu #"
Write-Host "#         Version 1.0          #"
Write-Host "#                              #"
Write-Host "################################"
Write-Host ""
write-Host "1. View Default File Pool Policy Information"
write-Host "2. Modify Default File Pool "
write-Host "3. List File Pool Policy Templates"
write-Host "4. View Details of File Pool Policy Template"
write-Host "5. Create File Pool Policy"
write-Host "6. Modify Existing File Pool Policy"
Write-Host "7. Exit Menu "
Write-Host ""
$FilePoolselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($FilePoolselection)
{
1 { ViewDefaultFilePoolPolicyInformation }
2 { ModifyDefaultFilePool }
3 { ListFilePoolPolicyTemplates }
4 { ViewFilePoolPolicyTemplateDetails }
5 { CreateFilePoolPolicy }
6 { ModifyExistingFilePoolPolicy }
7 { FilePool_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#StoragePools
function GetStoragePoolSettings {
}
function ModifyStoragePoolSettings {
}
function ListAllTiers {
}
function ViewTierSettings {
}
function CreateNewTier {
}
function DeleteSingleTier {
}
function DeleteAllTiers {
}
function ListNodePools {
}
function ViewNodePoolInformation {
}
function ModifyNodePool {
}
function DeleteManuallyManagedNodePool {
}
function StoragePools_Exit {
Clear-Host
MainMenu
}
function StoragePools_Menu {
Write-Host "###################################"
Write-Host "#                                 #"
Write-Host "# OneFS StoragePools Options Menu #"
Write-Host "#           Version 1.0           #"
Write-Host "#                                 #"
Write-Host "###################################"
Write-Host ""
Write-Host "1.  Get StoragePool Settings"
Write-Host "2.  Modify StoragePool Settings"
Write-Host "3.  List All Tiers"
Write-Host "4.  View Tier Settings"
Write-Host "5.  Create New Tier"
Write-Host "6.  Delete Single Tier"
Write-Host "7.  Delete All Tiers"
Write-Host "8.  List Node Pools"
Write-Host "9.  View Specific Node Pool Information"
Write-Host "10. Modify Node Pool"
Write-Host "11. Delete Manually Managed Node Pool"
Write-Host "12. Exit Menu "
Write-Host ""
$StoragePoolselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($StoragePoolselection)
{
1 { GetStoragePoolSettings }
2 { ModifyStoragePoolSettings }
3 { ListAllTiers }
4 { ViewTierSettings }
5 { CreateNewTier }
6 { DeleteSingleTier }
7 { DeleteAllTiers }
8 { ListNodePools }
9 { ViewNodePoolInformation }
10 { ModifyNodePool }
11 { DeleteManuallyManagedNodePool }
12 { StoragePools_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#SmartLock
function ListAllSmartLockDomains {
}
function ViewSmartLockDomainDetails {
}
function CreateSmartLockDomain {
}
function ModifySmartLockDomain {
}
function SmartLock_Exit {
Clear-Host
MainMenu
}
function SmartLock_Menu {
Write-Host "################################"
Write-Host "#                              #"
Write-Host "# OneFS SmartLock Options Menu #"
Write-Host "#          Version 1.0         #"
Write-Host "#                              #"
Write-Host "################################"
Write-Host ""
Write-Host "1. List All SmartLock Domains"
Write-Host "2. View SmartLock Domain Details"
Write-Host "3. Create SmartLock Domain"
Write-Host "4. Modify SmartLock Domain"
Write-Host "5. Exit Menu "
Write-Host ""
$SmartLockselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($SmartLockselection)
{
1 { ListAllSmartLockDomains }
2 { ViewSmartLockDomainDetails }
3 { CreateSmartLockDomain }
4 { ModifySmartLockDomain }
5 { SmartLock_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#HDFS-Hadoop
function GetAllHDFSRacks {
}
function CreateHDFSRack {
}
function ViewHDFSRack {
}
function ModifyExistingHDFSRack {
}
function DeleteHDFSRack {
}
function ListHDFSProxyUsers {
}
function ViewHDFSProxyUser {
}
function CreateHDFSProxyUser {
}
function DeleteHDFSProxyUser {
}
function ListHDFSProxyUserMembers {
}
function HDFSProxyUser-AddMember {
}
function RHDFSProxyUser-RemoveMember {
}
function ViewGlobalHDFSSettings {
}
function ModifyGlobalHDFSSettings {
}
function HDFS_Exit {
Clear-Host
MainMenu
}
function HDFSHadoop_Menu {
Write-Host "###########################"
Write-Host "#                         #"
Write-Host "# OneFS HDFS Options Menu #"
Write-Host "#        Version 1.0      #"
Write-Host "#                         #"
Write-Host "###########################"
Write-Host ""
Write-Host "1.  Get All HDFS Racks "
Write-Host "2.  Create an HDFS Rack "
Write-Host "3.  View an HDFS Rack "
Write-Host "4.  Modify Existing HDFS Rack "
Write-Host "5.  Delete an HDFS Rack "
Write-Host "6.  List All HDFS Proxy Users "
Write-Host "7.  View a Specific HDFS Proxy User "
Write-Host "8.  Create an HDFS Proxy User "
Write-Host "9.  Delete an HDFS Proxy User "
Write-Host "10. List Members of an HDFS Proxy User "
Write-Host "11. Add a Member to an HDFS Proxy User "
Write-Host "12. Remove a Member from an HDFS Proxy User "
Write-Host "13. View Global HDFS Settings "
Write-Host "14. Modify Global HDFS Settings "
Write-Host "15. Exit Menu "
Write-Host ""
$HDFSselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($HDFSselection)
{
1 { GetAllHDFSRacks }
2 { CreateHDFSRack }
3 { ViewHDFSRack }
4 { ModifyExistingHDFSRack }
5 { DeleteHDFSRack }
6 { ListHDFSProxyUsers }
7 { ViewHDFSProxyUser }
8 { CreateHDFSProxyUser }
9 { DeleteHDFSProxyUser }
10{ ListHDFSProxyUserMembers }
11{ HDFSProxyUser-AddMember }
12 { RHDFSProxyUser-RemoveMember }
13 { ViewGlobalHDFSSettings }
14 { ModifyGlobalHDFSSettings }
15 { HDFS_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#Access Zones
function ListAllAccessZones {}
function ViewSpecificAccessZone {}
function ViewSettingsAllAccessZones {}
function Non-PrivilegedAccessZoneInformation {}
function CreateAccessZone {}
function ModifyAccessZone {}
function DeleteAccessZone {}
function AccessZone_Exit {
Clear-Host
MainMenu
}
function AccessZones_Menu {
Write-Host "##################################"
Write-Host "#                                #"
Write-Host "# OneFS Access Zone Options Menu #"
Write-Host "#           Version 1.0          #"
Write-Host "#                                #"
Write-Host "##################################"
Write-Host ""
Write-Host "1. List All Access Zones "
Write-Host "2. View Specific Access Zone "
Write-Host "3. View Settings for All Access Zones "
Write-Host "4. View Non-Privileged Information about Specific Access Zone "
Write-Host "5. Create an Access Zone "
Write-Host "6. Modify an Access Zone "
Write-Host "7. Delete an Access Zone "
Write-Host "8. Exit Menu "
Write-Host ""
$AccessZoneselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($AccessZoneselection)
{
1 { ListAllAccessZones }
2 { ViewSpecificAccessZone }
3 { ViewSettingsAllAccessZones }
4 { Non-PrivilegedAccessZoneInformation }
5 { CreateAccessZone }
6 { ModifyAccessZone }
7 { DeleteAccessZone }
8 { AccessZone_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#Cluster Statistics
function Stats_Exit {
Clear-Host
MainMenu
}
function ClusterStatistics_Menu {
Write-Host "#########################################"
Write-Host "#                                       #"
Write-Host "# OneFS Cluster Statistics Options Menu #"
Write-Host "#              Version 1.0              #"
Write-Host "#                                       #"
Write-Host "#########################################"
Write-Host ""
Write-Host "1. Exit Menu "
Write-Host ""
$Statselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Statselection)
{
1 { Stats_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#Custom Scripts
function DataAreaCreation {}
function AddRootClientsNFSexports {}
function AddGroupRunAsRootSMBshares {}
function CustomerScript_Exit {
Clear-Host
MainMenu
}
function CustomScripts_Menu {
Write-Host "##########################"
Write-Host "#                        #"
Write-Host "# OneFS Customer Scripts #"
Write-Host "#       Version 1.0      #"
Write-Host "#                        #"
Write-Host "##########################"
Write-Host ""
Write-Host "1. Data Area Creation"
Write-Host "2. Add Root-Client to all NFS Exports"
Write-Host "3. Add Group Run-As-Root Privileges on all SMB Shares"
Write-Host "4. Exit Menu "
Write-Host ""
$Customselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Customselection)
{
1 { DataAreaCreation }
2 { AddRootClientsNFSexports }
3 { AddGroupRunAsRootSMBshares }
4 { CustomerScript_Exit }
default { Write-Host "Please make a valid selection from the list"}
}
}
#MainMenuFunctions
function MainMenuExitMenu {}
function MainMenu {
Write-Host "###############################"
Write-Host "#                             #"
Write-Host "#  OneFS Config Options Menu  #"
Write-Host "#         Version 1.0         #"
Write-Host "#                             #"
Write-Host "###############################"
Write-Host ""
Write-Host "1.  Snapshots "
Write-Host "2.  SMB Shares "
Write-Host "3.  NFS Exports "
Write-Host "4.  SmartQuotas "
Write-Host "5.  SyncIQ "
Write-Host "6.  Auditing "
Write-Host "7.  System Jobs "
Write-Host "8.  De-Duplication "
Write-Host "9.  File Pools "
Write-Host "10. StoragePools "
Write-Host "11. SmartLock "
Write-Host "12. HDFS / Hadoop "
Write-Host "13. Access Zones "
Write-Host "14. Cluster Statistics "
Write-Host "15. Custom Scripts "
Write-Host "16. Exit Menu"
Write-Host ""
$Menuselection = Read-Host -Prompt "Enter selection: "
#switch
switch ($Menuselection)
{
1 { SnapshotsMenu }
2 { SMBShare_Menu }
3 { NFSExport_Menu }
4 { SmartQuotas_Menu }
5 { SyncIQ_Menu }
6 { Auditing_Menu }
7 { SystemJobs_Menu }
8 { DeDuplication_Menu }
9 { FilePools_Menu }
10 { StoragePools_Menu }
11 { SmartLock_Menu }
12 { HDFSHadoop_Menu }
13 { AccessZones_Menu }
14 { ClusterStatistics_sMenu }
15 { CustomScripts_Menu }
16 { Exit }
default {Write-Host "Please make a valid selection from the list"}
}
}

#########
# Begin #
#########
Write-Host "Greetings, $env:Username !"
Write-Host ""
MainMenu