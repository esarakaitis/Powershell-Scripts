get-cluster "Cluster" | Get-VMHost | Get-VirtualSwitch -name "vSwitch0" | New-VirtualPortGroup "VLAN" -vlanid 123