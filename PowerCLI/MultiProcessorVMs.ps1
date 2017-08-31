$vc = Get-VIServer virtualcenter2
Get-VM | Where {$_.NumCPU -gt 1} | Write-Output