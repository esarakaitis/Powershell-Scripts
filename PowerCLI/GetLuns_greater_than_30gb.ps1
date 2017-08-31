$global:VIServer = Get-VIServer -Server virtualcenter2
Get-VMhost | Get-Datastore | `
where { $_.Name  -notlike  "localvmfs*"  -and  $_.FreeSpaceMB  -gt  "30000" }