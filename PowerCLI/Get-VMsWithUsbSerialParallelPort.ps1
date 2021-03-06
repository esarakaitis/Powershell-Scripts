Get-VM | ForEach-Object {
	$VM = Get-View $_.ID
	$HW = $VM.Config.Hardware.Device
	foreach ($dev in $HW){
		if (($dev.DeviceInfo.Label -like "Parallel Port *") -or
			($dev.DeviceInfo.Label -like "Serial Port *") -or
			($dev.DeviceInfo.Label -like "USB Port *"))
		{
			$dev | Select-Object @{Name="VM_Name"; Expression={$VM.Name}}, @{Name="Device"; Expression={$_.DeviceInfo.Label}}
		}
	}
}