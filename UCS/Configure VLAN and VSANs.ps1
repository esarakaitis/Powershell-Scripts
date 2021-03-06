#CREATE VLANS
#Get-UcsLanCloud | Add-UcsVlan -Name ESX_MGMT -Id 102
#Get-UcsLanCloud | Add-UcsVlan -Name ESX_VMKernel -Id 104
#Get-UcsLanCloud | Add-UcsVlan -Name Utility -Id 108
#Get-UcsLanCloud | Add-UcsVlan -Name VC_SQL -Id 110
#Get-UcsLanCloud | Add-UcsVlan -Name Ascend_Portal_DNS -Id 299

#CREATE VSANS
#Get-UcsFiSanCloud -Id A | Add-UcsVsan -Name VSAN_10 -Id 10 -fcoevlan 10 -zoningstate disabled
#Get-UcsFiSanCloud -Id B | Add-UcsVsan -Name VSAN_20 -Id 20 -fcoevlan 20 -zoningstate disabled

#CONFIGURE QOS
#get-ucsqosclass bronze | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
#get-ucsqosclass gold | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
#get-ucsqosclass platinum | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
#get-ucsqosclass silver | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled
#get-ucsqosclass best-effort | set-ucsqosclass -mtu 9000 -Force -Adminstate enabled

#CONFIGURE SAN PORTS TO VSAN
#NOTWORKING add-UcsVsanMemberFcPort -vsan 10 -portid 13 -slotid 2 -adminstate enabled -switchid A
#NOTWORKING add-UcsVsanMemberFcPort -vsan 10 -portid 13 -slotid 2 -adminstate enabled -switchid A
#NOTWORKING add-UcsVsanMemberFcPort -vsan 20 -portid 13 -slotid 2 -adminstate enabled -switchid B
#NOTWORKING add-UcsVsanMemberFcPort -vsan 20 -portid 13 -slotid 2 -adminstate enabled -switchid B

#ADD Managment IP Pool Block
#add-ucsippoolblock -IpPool "ext-mgmt" -from 172.27.80.32 -to 172.27.80.95 -defgw 172.27.80.1 -modifypresent:$true

#Create VSG Portal User
#Add-UcsLocalUser -Name vsg-portal -Pwd Mr8Ps8r7 -FirstName vsg -Lastname portal 

#Create VSG-Network Role
#NOTWORKING add-ucsuserrole -name "vsg-network" -localuser "vsg-portal"

#Configure NTP
#add-ucsntpserver -name 216.195.93.29
#add-ucsntpserver -name 216.195.93.89

#Configure TimeZone
#set-ucstimezone -timezone "America/New_York (Eastern Time)" -Force

#Configure SNMP Community
#set-ucssnmp -community "r014890Gh3y" -syscontact ENOC -syslocation "Ascend Learning Hamilton, Ohio" -adminstate enabled -force

#Configure SNMP Traps
#add-ucssnmptrap -hostname 216.195.93.19 -community "r014890Gh3y" -notificationtype traps -port 162 -version v2c
#add-ucssnmptrap -hostname 216.195.93.20 -community "r014890Gh3y" -notificationtype traps -port 162 -version v2c

#Create QOS Policies
#Start-UcsTransaction
#$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name BE
#$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "best-effort" -Rate line-rate
#Complete-UcsTransaction

#Start-UcsTransaction
#$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Bronze
#$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "bronze" -Rate line-rate
#Complete-UcsTransaction

#Start-UcsTransaction
#$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Gold
#$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "gold" -Rate line-rate
#Complete-UcsTransaction

#Start-UcsTransaction
#$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Platinum
#$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "platinum" -Rate line-rate
#Complete-UcsTransaction

#Start-UcsTransaction
#$mo = Get-UcsOrg -Level root  | Add-UcsQosPolicy -Name Silver
#$mo_1 = $mo | Add-UcsVnicEgressPolicy -ModifyPresent -Burst 10240 -HostControl none -Prio "silver" -Rate line-rate
#Complete-UcsTransaction

#create local disk policy
#Add-UcsLocalDiskConfigPolicy -name Local_Raid1 -descr Raid1_LocalDisk -mode raid-mirrored -protectconfig:$true

#create scrub policy
#add-ucsscrubpolicy -org root -name Format_Disk -Desc Format_the_disk -DiskScrub yes -BiosSettingsScrub no

#create default mac pool
#add-ucsmacmemberblock -macpool default -from "00:25:B5:00:00:00" -to "00:25:B5:00:00:0F"

#create iscsi pool block
#add-ucsippoolblock -IpPool "iscsi-initiator-pool" -from 0.0.0.1 -to 0.0.0.1 -modifypresent:$true

#create default wwn node pool block
#add-ucswwnmemberblock -wwnpool node-default -from  20:00:00:25:B5:00:00:00 -to 20:00:00:25:B5:00:00:07