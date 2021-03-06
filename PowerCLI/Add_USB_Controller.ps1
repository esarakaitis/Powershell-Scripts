$spec = New-Object VMware.Vim.VirtualMachineConfigSpec

$deviceCfg = New-Object VMware.Vim.VirtualDeviceConfigSpec
$deviceCfg.operation = "add"
$deviceCfg.device = New-Object VMware.Vim.VirtualUSBController
$deviceCfg.device.key = -1
$deviceCfg.device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
$deviceCfg.device.connectable.startConnected = $true
$deviceCfg.device.connectable.allowGuestControl = $false
$deviceCfg.device.connectable.connected = $true
$deviceCfg.device.controllerKey = 100
$deviceCfg.device.busNumber = -1
$deviceCfg.device.autoConnectDevices = $true

$spec.deviceChange += $deviceCfg

$vm = foreach ($vm in get-cluster standalone2 | Get-VM | Get-View)
    {
        $vm.ReconfigVM_Task($spec)
    }
