
 Get-VM -Server $viServers | Get-VMResourceConfiguration | where {$_.MemLimitMB -ne '-1'} | Set-VMResourceConfiguration -MemLimitMB $null 
