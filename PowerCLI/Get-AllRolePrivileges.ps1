#Must already be connected to a viserver. This works on the default vi server.
$si = Get-View ServiceInstance
$am = Get-View ($si.Content.AuthorizationManager)

foreach ($role in $am.RoleList)
{
    foreach ($privilege in $role.Privilege)
    {
        $role | Select-Object RoleId, System, Name,
                             @{Name="Privilege"; Expression={$privilege}}
    }
}
