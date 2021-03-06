# Usage: <template object(s)> | .\Upgrade-ToolsTemplate.ps1
# Example: Get-Template template1 | .\Upgrade-ToolsTemplate.ps1
#          Get-Datacenter corporate | Get-Template | .\Upgrade-ToolsTemplate.ps1
# Note: When getting template make sure to get the correct datacenter in case
#       there are duplicate names.

BEGIN
{
    $sleeptime = 60
}

PROCESS
{
    "Converting {0} to VM" -f $_.Name
    $vm = $_ | Set-Template -ToVM

    "Powering on the VM: {0}" -f $vm.Name
    $vm | Start-VM | Out-Null

    #TODO: Find a better way of doing this than just sleeping.  Perhaps poll 
    #      on tools status.
    "Sleeping for $sleeptime seconds"
    Start-Sleep -Seconds $sleeptime

    $vmview = Get-View $vm.ID
    "Existing Tools Version {0}" -f $vmview.config.tools.toolsVersion

    "Upgrading Tools"
    $vm | Update-Tools

    "Sleeping for $sleeptime seconds"
    Start-Sleep -Seconds $sleeptime

    $vmview = Get-View $vm.ID
    "New Tools Version {0}" -f $vmview.config.tools.toolsVersion

    "Powering off the VM: {0}" -f $vm.Name
    $vm | Stop-VM -confirm:$false | Out-Null

    "Converting to template"
    $vmview.MarkAsTemplate()
}