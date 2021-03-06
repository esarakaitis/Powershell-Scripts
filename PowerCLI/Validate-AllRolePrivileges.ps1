#Must already be connected to a viserver. This works on the default vi server.
$si = Get-View ServiceInstance
$am = Get-View ($si.Content.AuthorizationManager)

# Get the gold standard
$goldRolePrivs = Import-Csv RolePrivMasterList.csv)

# Get the current settings and do a comparison
$currRolePrivs = @{}
foreach ($role in $am.RoleList)
{
    foreach ($privilege in $role.Privilege)
    {
        $rolePriv = $role | Select-Object RoleId, System, Name,
                             @{Name="Privilege"; Expression={$privilege}}
        
        # Add a property to keep track of the status
        $rolePriv | Add-Member -MemberType NoteProperty -Name Status -Value "Untested"
        
        $rolePrivKey = "{0}:{1}" -f $rolePriv.RoleId, $rolePriv.Privilege
        
        if ($goldRolePrivs.ContainsKey($rolePrivKey))
        {
            
        }
        else
        {
            $rolePriv.Status = "Extra"
        }
        
        # Anything left in the master list is missing
    }
}
