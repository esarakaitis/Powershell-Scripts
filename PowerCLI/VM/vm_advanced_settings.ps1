# Usage: <vmobject> | .\Configure-VmAdvancedSettings.ps1
# Examples: Get-VM myTestVM | .\Configure-VmAdvancedSettings.ps1
#           Get-Cluster myCluster | Get-VM | .\Configure-VmAdvancedSettings.ps1
 
BEGIN
{
    # The settings as an array of arrays.  ("key", "value)
    $advancedSettings = @( ("isolation.tools.setGUIOptions.enable", "false"),
                           ("isolation.tools.connectable.disable", "true"),
                           ("isolation.device.connectable.disable", "true"),
                           ("isolation.tools.diskWiper.disable", "true"),
                           ("isolation.tools.diskShrink.disable", "true")
                         )
    $keyIndex = 0
    $valueIndex = 1
}
 
PROCESS
{                      
    $vmView = Get-View $_.Id
    $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
 
    foreach ($setting in $advancedSettings)
    {
        $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
        $vmConfigSpec.extraconfig[-1].Key = $setting[$keyIndex]
        $vmConfigSpec.extraconfig[-1].Value = $setting[$valueIndex]
    }
    $vmView.ReconfigVM($vmConfigSpec)
}