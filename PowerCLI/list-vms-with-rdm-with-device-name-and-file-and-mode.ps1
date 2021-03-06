$report = @()
$vms = Get-VM | Get-View
foreach($vm in $vms){
foreach($dev in $vm.Config.Hardware.Device){
if(($dev.gettype()).Name -eq “VirtualDisk”){
if(($dev.Backing.CompatibilityMode -eq “physicalMode”) -or
($dev.Backing.CompatibilityMode -eq “virtualMode”)){
$row = “” | select VMName, HDDeviceName, HDFileName, HDMode
$row.VMName = $vm.Name
$row.HDDeviceName = $dev.Backing.DeviceName
$row.HDFileName = $dev.Backing.FileName
$row.HDMode = $dev.Backing.CompatibilityMode
$report += $row
}
}
}
}
$report