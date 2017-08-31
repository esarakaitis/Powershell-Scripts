Get-VM |% {Get-View $_.ID} |`

% {
$vmVersion = $_.Config.Version
$vmName = $_.Name

    if ($vmVersion -eq "vmx-04"){
        Write-Host $vmName "uses hardware version 4"
    }
}
