foreach ($vm in Get-VM)
{
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.changeVersion = $vm.ExtensionData.Config.ChangeVersion
$spec.tools = New-Object VMware.Vim.ToolsConfigInfo
$spec.tools.syncTimeWithHost = $false
 
$_this = Get-View -Id $vm.Id
$_this.ReconfigVM_Task($spec)
}