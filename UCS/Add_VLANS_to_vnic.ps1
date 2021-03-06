$1host = "vdiesx36"
get-ucsserviceprofile $1host | Get-UcsVnic eth0 | add-UcsVnicInterface -name VLAN101_ESX_MGMT -defaultnet true
get-ucsserviceprofile $1host | Get-UcsVnic eth1 | add-UcsVnicInterface -name VLAN101_ESX_MGMT -defaultnet true
get-ucsserviceprofile $1host | Get-UcsVnic eth2_vmk | add-UcsVnicInterface -name VLAN102_ESX_VMKernel 
get-ucsserviceprofile $1host | Get-UcsVnic eth3_vmk | add-UcsVnicInterface -name VLAN102_ESX_VMKernel 
get-ucsserviceprofile $1host | Get-UcsVnic eth4_guest | add-UcsVnicInterface -name VLAN103_VC_SQL
get-ucsserviceprofile $1host | Get-UcsVnic eth5_guest | add-UcsVnicInterface -name VLAN103_VC_SQL
get-ucsserviceprofile $1host | Get-UcsVnic eth4_guest | add-UcsVnicInterface -name VLAN125_XenApp
get-ucsserviceprofile $1host | Get-UcsVnic eth5_guest | add-UcsVnicInterface -name VLAN125_XenApp
get-ucsserviceprofile $1host | Get-UcsVnic eth4_guest | add-UcsVnicInterface -name VLAN126_XenDesktop
get-ucsserviceprofile $1host | Get-UcsVnic eth5_guest | add-UcsVnicInterface -name VLAN126_XenDesktop