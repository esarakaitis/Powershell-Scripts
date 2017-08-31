######################################################################################################################################################
#                                                                                                                                                    #
# Created: 02/11/2016  by Adam Fowler, EMC Implementation Delivery Specialist II Central Division                                                    #
# Modified: 2/11/2016 by AF, Add more specifics to which node client is connecting to                                                                #
#                                                                                                                                                    #
# ps_get_client_connections_via_papi.ps1                                                                                                             #
#                                                                                                                                                    #
# PARAMETERS                                                                                                                                         #
#                                                                                                                                                    #
# -isilonip = node IP                                                                                                                                #
# -username                                                                                                                                          #
# -password                                                                                                                                          #
#                                                                                                                                                    #
# EXAMPLE                                                                                                                                            #
# .\ps_get_client_connections_via_papi.ps1 -isilonip 10.10.10.1 -user root -password P@ssword1                                                       #
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
   write ".\ps_get_client_connections_via_papi.ps1 -isilonip 10.10.10.1 -user root -password P@ssword1 " ;
   exit
}

###############################
# Get HTTP Active Connections #
###############################
$resource="/platform/1/statistics/current?key=node.clientstats.active.http&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(HTTP)/Node$dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.proto.http&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(HTTP)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.http&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(HTTP)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

########################
# Get PAPI Connections #
########################
$resource="/platform/1/statistics/current?key=node.clientstats.proto.papi&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(PAPI)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.papi&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(PAPI)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.papi&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(PAPI)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

#############################################
# Get CIFS / SMB1 / SMB2 / SMB3 Connections #
#############################################
$resource="/platform/1/statistics/current?key=node.clientstats.proto.smb1&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB1)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.smb1&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB1)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.smb&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.proto.smb2&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB2)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.smb2&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB2)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.cifs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB1)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.cifs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB1)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.proto.cifs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(SMB1)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}


###############################
# Get NFS3 / NFS4 Connections #
###############################
$resource="/platform/1/statistics/current?key=node.clientstats.proto.nfs3&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected NFS3 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS3)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.nfs3&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected NFS3 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS3)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.nfs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected NFS3 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.proto.nfs4&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS4)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.nfs4&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS4)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.nfs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.proto.nfs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(NFS)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

########################
# Get HDFS Connections #
########################
$resource="/platform/1/statistics/current?key=node.clientstats.proto.hdfs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(HDFS)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.hdfs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(HDFS)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.hdfs&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected SMB2 Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(HDFS)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

########################
# Get FTP Connections  #
########################
$resource="/platform/1/statistics/current?key=node.clientstats.proto.ftp&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(FTP)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.active.ftp&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(FTP)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}

$resource="/platform/1/statistics/current?key=node.clientstats.connected.ftp&nodes=all&degraded=true&interval=30&memory_only=true"
$headers = @{"Authorization"="Basic $($EncodedPassword)"}
$uri = $baseurl + $resource
$ISIObject = Invoke-RestMethod -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Method GET
#Write-Host "Connected FTP Clients:" -BackgroundColor Cyan -ForegroundColor Black
#Loop through Each Connection
ForEach($stats in $ISIObject.stats) {
$dev_id = $stats.devid
$node = $stats.value.local_addr
$remoteclient = $stats.value.remote_addr
IF([string]::IsNullOrEmpty($remoteclient)) {} else {
Write-Host $remoteclient "(FTP)/Node $dev_id($node)" -BackgroundColor Black -ForegroundColor White
}
}
