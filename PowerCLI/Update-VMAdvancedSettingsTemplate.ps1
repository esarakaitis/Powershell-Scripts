PROCESS
{
    $vm = Get-Template | Set-Template -ToVM
    $vm | .\Configure-VmAdvancedSettings.ps1
    $vmview = Get-View $vm.ID
    $vmview.MarkAsTemplate()
}