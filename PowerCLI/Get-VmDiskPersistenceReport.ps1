Get-VM | ForEach-Object {
    $vmname = $_.Name
    $_.HardDisks | Select-Object @{Name="VM"; Expression={$vmname}}, Filename, Persistence
}