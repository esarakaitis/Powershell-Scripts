$esxHosts = Get-VMHost | Sort Name
    foreach($esx in $esxHosts){
        Write-Host "Enabling VAAI"
        Set-VMHostAdvancedConfiguration -VMHost $esx -Name DataMover.HardwareAcceleratedMove -Value 1 -Confirm:$false
        Set-VMHostAdvancedConfiguration -VMHost $esx -Name DataMover.HardwareAcceleratedInit -Value 1 -Confirm:$false
        Set-VMHostAdvancedConfiguration -VMHost $esx -Name VMFS3.HardwareAcceleratedLocking -Value 1 -Confirm:$false
    }