# Usage: <vmobject> | .\Validate-VmAdvancedSettings.ps1
# Examples: Get-VM myTestVM | .\Validate-VmAdvancedSettings.ps1
#           Get-Cluster myCluster | Get-VM | .\Validate-VmAdvancedSettings.ps1

BEGIN
{
    # The settings as an array of arrays.  ("key", "value)
    $advancedSettings = @( ("isolation.tools.copy.disable", "true"),
                           ("isolation.tools.paste.disable", "true"),
                           ("isolation.tools.setGUIOptions.enable", "false"),
                           ("log.rotateSize", "100000"),
                           ("log.keepOld", "10"),
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
    
    # Get the existing settings in an easy lookup format.
    $vmSettings = @{}
    foreach ($item in $vmView.Config.ExtraConfig)
    {
        $vmSettings[$item.Key] = $item.Value
    }
  
    # Validate each of the advanced settings.
    foreach ($setting in $advancedSettings)
    {
        $status = $null
        if (!$vmSettings.ContainsKey($setting[$keyIndex]))
        {
            $status = "Missing"
        }
        elseif ($vmSettings[$setting[$keyIndex]] -ne $setting[$valueIndex])
        {
            $status = "Misconfigured"
        }
        else
        {
            $status = "Ok"
        }
        
        $vmView | Select-Object Name, 
                                @{Name="Setting"; Expression={$setting[$keyIndex]}},
                                @{Name="Status"; Expression={$status}}
    }
}