$vserver = Get-VIServer virtualcenter2

Get-VMHost | % {$vmhost = $_; (Get-View $vmhost.ID).Config.ConsoleReservation | Select-Object @{Name="Hostname"; Expression={$vmhost.Name}}, ServiceConsoleReservedCfg, ServiceConsoleReserved}