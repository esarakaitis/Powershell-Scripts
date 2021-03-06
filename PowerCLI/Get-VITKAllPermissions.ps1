Function Get-VITKAllPermissions
{
    $si = Get-View ServiceInstance
    $am = Get-View $si.Content.AuthorizationManager

    # Create the role map
    $roleMap = @{}
    # Add the roles to the map
    foreach ($role in $am.RoleList)
    {
        $roleMap[$role.RoleId] = $role
    }

    # Foreach permission
    foreach ($permission in $am.RetrieveAllPermissions())
    {
        $roleName = $roleMap[$permission.RoleId].Name
        $entityView = Get-View $permission.Entity
        $permission | Select-Object @{Name="Principal"; Expression={$permission.Principal}},
                                    @{Name="RoleName"; Expression={$roleName}},
                                    @{Name="Object"; Expression={Get-VIObjectPath $entityView}}
    }
}

Function Get-VITKObjectPath($object)
{
    # Try to handle non view objects by checking if a parent property
    # exists and getting the view of the object if it does not.  Even
    # the root objects will have the property but it will be $null.
    if (-not ($object | Get-Member Parent))
    {
        $object = Get-View $object.ID
    }
	$path = $object.Name
	while($object.Parent -ne $null)
    {      
		$object = Get-View $object.Parent
		$path = $object.Name + "\" + $path
	}
	$path
}
