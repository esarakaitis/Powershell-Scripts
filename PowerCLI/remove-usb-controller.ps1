function Remove-UsbController{
 param($VMs )
foreach ($VMimpl in $VMs){
 $VM = Get-View $VMimpl.ID
 $i = 0
 $spec = new-object VMware.Vim.VirtualMachineConfigSpec
 $HW = $VM.Config.Hardware.Device
  foreach($dev in $HW){
   if (($dev|where {$_ -is [VMware.Vim.VirtualUSBController]})-is [VMware.Vim.VirtualUSBController])
   {
    $spec.DeviceChange += New-Object VMware.Vim.VirtualDeviceConfigSpec
    $spec.DeviceChange[$i].device = New-Object VMware.Vim.VirtualDevice
    $spec.DeviceChange[$i].device.key = $dev.Key
    $spec.DeviceChange[$i].operation = "remove" 
    
    $i++
   }
  }
  if ($i -gt 0) {$VM.ReconfigVM_Task($spec)}
}
}
get-cluster standalone1 | Remove-UsbController (Get-VM)