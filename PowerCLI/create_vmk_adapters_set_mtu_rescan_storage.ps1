#=============================================================================
#filename        :create_vmk_adapters_set_mtu_rescan_storage.ps1
#description     :This script is used to:
#                   - create vmkernel interfaces
#                   - create ip addresses on said interfaces
#                   - add intefaces to the dvswitch
#                   - set the mtu of the vmkernel interfaces
#author          :Eric Sarakaitis
#date            :9/22/16
#==============================================================================$esxi = "vmh26.afg1.nor1.ems.encore.tech"
#define the dvswitch that you want to leverage
$switch = Get-VirtualSwitch -Name "vcs1_afg1_nor1_dvs1"
#define the vmotion ip address
$vmotionipaddress = "10.99.19.35"
#define the iscsi_a porgroup ip address
$iscsiaipaddress = "10.99.17.35"
#define the iscsi_b porgroup ip address
$iscsibipaddress = "10.99.18.35"
#Create vMotion interface
New-VMHostNetworkAdapter -VMHost (get-vmhost $esxi) -PortGroup vMotion_VLAN_2653_10.99.19 -VirtualSwitch $switch -IP $vmotionipaddress -SubnetMask 255.255.255.0 -VMotionEnabled $false -mtu 9000
#Create iscsi_a interface
New-VMHostNetworkAdapter -VMHost (get-vmhost $esxi) -PortGroup iSCSI_A_VLAN_2651_10.99.17 -VirtualSwitch $switch -IP $iscsiaipaddress -SubnetMask 255.255.255.0 -VMotionEnabled $false -mtu 9000
#Create iscsi_b interface
New-VMHostNetworkAdapter -VMHost (get-vmhost $esxi) -PortGroup iSCSI_B_VLAN_2652_10.99.18 -VirtualSwitch $switch -IP $iscsibipaddress -SubnetMask 255.255.255.0 -VMotionEnabled $false -mtu 9000
#set mtu on the existing vmk0
Get-VMHost $esxi | Get-VMHostNetworkAdapter -name vmk0 | Where { $_.GetType().Name -eq "HostVMKernelVirtualNicImpl" } | Foreach { $_ | Set-VMHostNetworkAdapter -Mtu 9000 -Confirm:$false }
#configure CHAP on the software iscsi interface
get-vmhost $esxi | Get-VMHostHba -Device vmhba40 | Set-VMHosthba -ChapType Required -ChapName chap1.san1.afg1.nor1.ems.encore.tech -ChapPassword "XxN2HZJSF2rGj9b6"
#Rescan storage
get-vmhost $esxi | Get-VMHostStorage -RescanAllHBA