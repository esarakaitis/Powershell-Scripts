#get list of vms
$VMs = get-vmhost | Get-VM
#walk through vms
foreach ($VM in $VMs){
    #Write-Host ("Found a VM {0}" -f $VM.Name)
	$VMx = Get-View $VM.ID
	$HW = $VMx.Config.Hardware.Device
	foreach ($dev in $HW)
    {
		if ($dev.DeviceInfo.Label -like "Parallel Port *" -or $dev.DeviceInfo.Label -like "Serial Port *" -or $dev.DeviceInfo.Label -like "USB Controller *")
		{
		  $dev | select @{Name="VM_Name"; Expression={$VMx.Name}}, @{Name="Device"; Expression={$_.DeviceInfo.Label}}
		}
	}
}