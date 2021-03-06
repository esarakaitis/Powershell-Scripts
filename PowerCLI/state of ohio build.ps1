#get-cluster "Hamilton Managed Voice" | 
#Get-VMHost "172.22.138.12" | Get-VirtualSwitch -name "vSwitch0" | New-VirtualPortGroup "VLAN42" -vlanid 42
$vmserver = "172.22.138.17"
#get-vmhost $vmserver | Add-VMHostNtpServer -NtpServer "172.22.136.2"
#get-vmhost $vmserver | Add-VMHostNtpServer -NtpServer "172.22.136.3"
get-vmhost $vmserver | Get-VmHostService | Where-Object {$_.key -eq “ntpd“} | Start-VMHostService
get-vmhost $vmserver | Get-VmHostService | Where-Object {$_.key -eq “ntpd“} | set-VMHostService -Policy "Automatic"
#Get-VMHost $vmserver | Get-VirtualSwitch -name "vSwitch0" | New-VirtualPortGroup "VLAN42" -vlanid 42
#Get-VMHost $vmserver | Get-VirtualSwitch -name "vSwitch0" | New-VirtualPortGroup "VLAN120" -vlanid 120