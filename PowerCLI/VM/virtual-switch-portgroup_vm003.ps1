#build vmkernel vswitch/portgroup
$switch = New-VirtualSwitch -VMHost (get-vmhost) -Name vSwitch1 -Nic vmnic3
New-VirtualPortGroup -Name vmotion -VirtualSwitch $switch
New-VMHostNetworkAdapter -VMHost (get-vmhost) -PortGroup vmotion -VirtualSwitch $switch -IP 172.16.1.3 -SubnetMask 255.255.255.0 -VMotionEnabled $true
#build virtual machine vswitch/portgroup
get-vmhost | new-virtualswitch -name "vSwitch2" -nic vmnic0
Get-VMHost | Get-VirtualSwitch -name "vSwitch2" | New-VirtualPortGroup "build_subnet"
Get-VMHost | Get-VirtualSwitch -name "vSwitch2" | New-VirtualPortGroup "10.92.4.0_Team01"
#add second nic to team
$vs = get-virtualswitch -name vSwitch2 -vmhost (get-vmhost)
set-virtualswitch -virtualswitch $vs -nic vmnic2
#configure gateway for vmkernel
$vmhostnetwork = get-vmhostnetwork -vmhost (get-vmhost)
set-vmhostnetwork -network $vmhostnetwork -vmkernelgateway 172.16.1.254