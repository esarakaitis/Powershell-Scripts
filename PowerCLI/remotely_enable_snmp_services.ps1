Connect-VIServer vdiesx02.ccs.local -User root -Password RVm1cr0x
$vmhostsnmp = get-vmhostsnmp
Set-VMHostSnmp -Enabled:$true -HostSnmp $vmhostsnmp -ReadOnlyCommunity "r0017423Y8UY" -TargetHost "10.121.13.5"
Set-VMHostSnmp -Enabled:$true -HostSnmp $vmhostsnmp -ReadOnlyCommunity "r0017423Y8UY" -addtarget -TargetHost "10.121.13.6"
disconnect-viserver * -force

