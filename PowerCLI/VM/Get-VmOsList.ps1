Get-VM | Select-Object Name, @{Name="Installed OS"; Expression={$_.Guest.OSFullName}}, @{Name="Configured OS"; Expression={
        (Get-View $_.ID).Config.GuestFullName}}
