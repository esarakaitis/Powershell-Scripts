$fabavsan = VSAN_10
$fabavsanid = 10
$fabbvsan = VSAN_20
$fabbvsanid = 20
$customerportgroup = Ascend_Portal_DNS
$mgmt_ippoolstart = 172.27.80.32
$mgmt_ippoolfinish = 172.27.80.95
$mgmt_ippoolgw = 172.27.80.1
$ntp1 = 216.195.93.29
$ntp2 = 216.195.93.89
$snmpcomm = "r014890Gh3y"
$snmplocation = "Ascend Learning Hamilton"

#Add UCS FI Uplinks on FIA and FIB
add-ucsuplinkport -filancloud A -portid 17 -slotid 1
add-ucsuplinkport -filancloud A -portid 18 -slotid 1
add-ucsuplinkport -filancloud B -portid 17 -slotid 1
add-ucsuplinkport -filancloud B -portid 18 -slotid 1

#Add UCS FI Server Uplinks on FIA and FIB
add-ucsserverport -fabricservercloud A -portid 1 -slotid 1
add-ucsserverport -fabricservercloud A -portid 2 -slotid 1
add-ucsserverport -fabricservercloud A -portid 3 -slotid 1
add-ucsserverport -fabricservercloud A -portid 4 -slotid 1
add-ucsserverport -fabricservercloud B -portid 1 -slotid 1
add-ucsserverport -fabricservercloud B -portid 2 -slotid 1
add-ucsserverport -fabricservercloud B -portid 3 -slotid 1
add-ucsserverport -fabricservercloud B -portid 4 -slotid 1

#Configre Unified Ports to all be FC
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 1
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 2
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 3
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 4
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 5
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 6
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 7
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 8
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 9
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 10
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 11
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 12
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 13
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 14
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 15
Get-UcsFiSanCloud -Id “A” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 16
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 1
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 2
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 3
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 4
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 5
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 6
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 7
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 8
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 9
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 10
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 11
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 12
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 13
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 14
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 15
Get-UcsFiSanCloud -Id “B” | Add-UcsFcUplinkPort -ModifyPresent -AdminState “enabled” -SlotId 2 -PortId 16

#CREATE VLANS
Get-UcsLanCloud | Add-UcsVlan -Name ESX_MGMT -Id 102
Get-UcsLanCloud | Add-UcsVlan -Name ESX_VMKernel -Id 104
Get-UcsLanCloud | Add-UcsVlan -Name Utility -Id 108
Get-UcsLanCloud | Add-UcsVlan -Name VC_SQL -Id 110
Get-UcsLanCloud | Add-UcsVlan -Name $customerportgroup -Id 299

#CREATE VSANS
Get-UcsFiSanCloud -Id A | Add-UcsVsan -Name $fabavsan -Id $fabavsanid -fcoevlan $fabavsanid -zoningstate disabled
Get-UcsFiSanCloud -Id B | Add-UcsVsan -Name $fabbvsan -Id $fabbvsanid -fcoevlan $fabbvsanid -zoningstate disabled

#CONFIGURE QOS
get-ucsqosclass bronze | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
get-ucsqosclass gold | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
get-ucsqosclass platinum | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
get-ucsqosclass silver | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
get-ucsqosclass best-effort | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled

#CONFIGURE SAN PORTS TO VSAN
#NOTWORKING add-UcsVsanMemberFcPort -vsan 10 -portid 13 -slotid 2 -adminstate enabled -switchid A
#NOTWORKING add-UcsVsanMemberFcPort -vsan 10 -portid 13 -slotid 2 -adminstate enabled -switchid A
#NOTWORKING add-UcsVsanMemberFcPort -vsan 20 -portid 13 -slotid 2 -adminstate enabled -switchid B
#NOTWORKING add-UcsVsanMemberFcPort -vsan 20 -portid 13 -slotid 2 -adminstate enabled -switchid B

#ADD Managment IP Pool Block
add-ucsippoolblock -IpPool "ext-mgmt" -from $mgmt_ipoolstart -to $mgmt_ipoolfinish -defgw $mgmt_ipoolgw -modifypresent:$true

#Create VSG Portal User
Add-UcsLocalUser -Name vsg-portal -Pwd Mr8Ps8r7 -FirstName vsg -Lastname portal 

#Create VSG-Network Role
#NOTWORKING add-ucsuserrole -name "vsg-network" -localuser "vsg-portal"

#Configure NTP
add-ucsntpserver -name $ntp1
add-ucsntpserver -name $ntp2

#Configure TimeZone
set-ucstimezone -timezone "America/New_York (Eastern Time)" -Force

#Configure SNMP Community
set-ucssnmp -community $snmpcomm -syscontact ENOC -syslocation $snmplocation -adminstate enabled -force

#Configure SNMP Traps
add-ucssnmptrap -hostname 216.195.93.19 -community $snmpcomm -notificationtype traps -port 162 -version v2c
add-ucssnmptrap -hostname 216.195.93.20 -community $snmpcomm -notificationtype traps -port 162 -version v2c

#Create QOS Policies
Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name BE
$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "best-effort" -Rate line-rate
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Bronze
$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "bronze" -Rate line-rate
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Gold
$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "gold" -Rate line-rate
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Platinum
$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "platinum" -Rate line-rate
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Silver
$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "silver" -Rate line-rate
Complete-UcsTransaction

#create local disk policy
Add-UcsLocalDiskConfigPolicy -name Local_Raid1 -descr Raid1_LocalDisk -mode raid-mirrored -protectconfig:$true

#create scrub policy
add-ucsscrubpolicy -org root -name Format_Disk -Desc Format_the_disk -DiskScrub yes -BiosSettingsScrub no

#create default mac pool
add-ucsmacmemberblock -macpool default -from "00:25:B5:00:00:00" -to "00:25:B5:00:00:0F"

#create iscsi pool block
add-ucsippoolblock -IpPool "iscsi-initiator-pool" -from 0.0.0.1 -to 0.0.0.1 -modifypresent:$true

#create default wwn node pool block
add-ucswwnmemberblock -wwnpool node-default -from  20:00:00:25:B5:00:00:00 -to 20:00:00:25:B5:00:00:07