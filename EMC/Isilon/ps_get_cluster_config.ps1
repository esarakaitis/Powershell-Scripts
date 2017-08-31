######################################################################################################################################################
#                                                                                                                                                    #
# Created: 02/4/2016  by Adam Fowler, EMC Implementation Delivery Specialist II Central Division                                                     #
# Modified: 02/6/2016 by Adam Fowler - Set SMB/NFS/Quota output to single line per item.  Added Exit Message for failed parameters.                  #
#                                                                                                                                                    #
#                                                                                                                                                    #
# ps_get_cluster_config_via_papi.ps1 - GET SMB share & Permission, NFS export and Client List, Access Zone and Quota configuration                   #
#                                                                                                                                                    #
#                                                                                                                                                    #
# PARAMETERS                                                                                                                                         #
#                                                                                                                                                    #
# -isilonip = node IP                                                                                                                                #
# -username                                                                                                                                          #
# -password                                                                                                                                          #
#                                                                                                                                                    #
# EXAMPLE                                                                                                                                            #
# .\ps_isilon_add_root_access_all_shares_via_papi.ps1  -isilonip 10.10.10.1 -user root -password P@ssword1                                           #
#                                                                                                                                                    #
#                                                                                                                                                    #
######################################################################################################################################################

#########################
#                       #
# ACCEPTABLE PARAMETERS #
#                       #
#########################
Param([String]$isilonip,[String]$username,[String]$password)

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

##################################################################
#                                                                #
#                                                                #
#      GATHER SOURCE CLUSTER SMB/NFS/QUOTA/ZONES INFORMATION     #
#                                                                #
#                                                                #
##################################################################

# List Access Zones
$resource = "/platform/1/zones"
Write-Host "Access Zones"
Write-Host ""
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET

ForEach($zone in $ISIObject.zones) {
$zone_id = $zone.zone_id
$zone_name = $zone.id
$zone_path = $zone.path
$zone_providers = $zone.auth_providers
$zone_auditing = $zone.syslog_audit_events
$zone_syslog_fwd = $zone.syslog_forwarding_enabled
$zone_hdfs = $zone.hdfs_enabled
$zone_usermapping_rules = $zone.user_mapper_rules
Write-Host "'Zone ID: " $zone_id -Backgroundcolor Black -ForegroundColor White
Write-Host "'Zone Name: " $zone_name -Backgroundcolor Green -ForegroundColor White
Write-Host "'Zone Path: " $zone_path -Backgroundcolor Green -ForegroundColor White
Write-Host "'Auth Providers: " $zone_providers -Backgroundcolor Green -ForegroundColor White
Write-Host "'Auditing Events: " $zone_auditing -Backgroundcolor Green -ForegroundColor White
Write-Host "'Syslog Forwarding Enabled: " $zone_syslog_fwd -Backgroundcolor Green -ForegroundColor White
Write-Host "'HDFS Enabled: " $zone_hdfs -Backgroundcolor Green -ForegroundColor White
Write-Host "'User Mapping Rules: " $zone_usermapping_rules -Backgroundcolor Green -ForegroundColor White
Write-Host ""
}

# List NFS Exports
$resource = "/platform/2/protocols/nfs/exports"
Write-Host "NFS Exports"
Write-Host ""
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET

#List Exports to Host
ForEach($export in $ISIObject.exports) {
$export_id = $export.id
$export_paths = $export.paths
$export_clients = $export.clients
$export_roclients = $export.read_only_clients
$export_rwclients = $export.read_write_clients
$export_rootclients = $export.root_clients
$export_zone = $export.zone
Write-Host "'Export ID: " $export_id -Backgroundcolor Black -ForegroundColor White
Write-Host "'Export Path: " $export_paths -Backgroundcolor Green -ForegroundColor White
Write-Host "'Export Clients: " $export_clients -Backgroundcolor Green -ForegroundColor White
Write-Host "'Export R/O Clients: " $export_roclients -Backgroundcolor Green -ForegroundColor White
Write-Host "'Export R/W Clients: " $export_rwclients -Backgroundcolor Green -ForegroundColor White
Write-Host "'Export Root Clients: " $export_rootclients -Backgroundcolor Green -ForegroundColor White
Write-Host "'Export Zone: " $export_zone -Backgroundcolor Green -ForegroundColor White
Write-Host ""
}

# List SMB Exports
$resource = "/platform/1/protocols/smb/shares"
Write-Host "SMB Shares"
Write-Host ""
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET

#List Shares to Host
ForEach($share in $ISIObject.shares) {
$share_id = $share.id
$share_path = $share.path
$share_permission = $share.permissions
$shares_runasroot = $share.run_as_root.name
$permission_permissiontype = $share.permissions.permission_type
$permission_trustee = $share.permissions.trustee
$share_zone = $share.zid
Write-Host "'Share Name: " $share_id -Backgroundcolor Black -ForegroundColor White
Write-Host "'Share Path: " $share_path -Backgroundcolor Green -ForegroundColor White
Write-Host "'Share Permission: " $share_permission -Backgroundcolor Green -ForegroundColor White
Write-Host "'Run-As-Root Users: " $shares_runasroot -Backgroundcolor Green -ForegroundColor White
Write-Host "'Share Permission Type: " $permission_permissiontype -Backgroundcolor Green -ForegroundColor White
Write-Host "'Trustee: " $permission_trustee -Backgroundcolor Green -ForegroundColor White
Write-Host "'Share Zone ID: " $share_zone -Backgroundcolor Green -ForegroundColor White
Write-Host ""
}


# List Isilon Quotas
$resource = "/platform/1/quota/quotas"
Write-Host "Cluster Quotas"
Write-Host ""
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET

#List Quotas to Host
ForEach($quota in $ISIObject.quotas) {
$quota_path = $quota.path
$quota_type = $quota.type
$quota_container = $quota.container
$quota_enforced = $quota.enforced
$quota_advisory_quota = $quota.thresholds.advisory
$hard_quota = $quota.thresholds.hard
$soft_quota = $quota.thresholds.soft
$soft_grace = $quota.thresholds.soft_grace
Write-Host "'Quota Path: " $quota_path -Backgroundcolor Black -ForegroundColor White 
Write-Host "'Quota Type: " $quota_type -Backgroundcolor Green -ForegroundColor White
Write-Host "'Container: " $quota_container -Backgroundcolor Green -ForegroundColor White
Write-Host "'Enforced: " $quota_enforced -Backgroundcolor Green -ForegroundColor White
Write-Host "'Advisory Limit: " $quota_advisory_quota -Backgroundcolor Green -ForegroundColor White
Write-Host "'Hard Threshold: " $hard_quota -Backgroundcolor Green -ForegroundColor White
Write-Host "'Soft Threshold: " $soft_quota -Backgroundcolor Green -ForegroundColor White
Write-Host "'Soft Grace Period: " $soft_grace -Backgroundcolor Green -ForegroundColor White
Write-Host ""
}

