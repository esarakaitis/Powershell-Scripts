Function Get-Path($entity){
	$path = $entity.Name
	while($entity.Parent -ne $null){
		$entity = Get-View -Id $entity.Parent
		if($entity.Name -ne "vm" -and $entity.Name -ne "host"){
			$path = $entity.Name + "\" + $path
		}
	}
	$path
}

$si = Get-View ServiceInstance
$am = Get-View $si.Content.AuthorizationManager

$roleList = $am.RoleList

# Create the role map
$roleMap = @{}
# Add the roles to the map
foreach ($role in $roleList)
{
    $roleMap[$role.RoleId] = $role
}

$permissions = $am.RetrieveAllPermissions()
# Foreach permission
foreach ($permission in $permissions)
{
    $roleName = $roleMap[$permission.RoleId].Name
    $entityView = Get-View $permission.Entity
    $permission | Select-Object @{Name="Principal"; Expression={$permission.Principal}},
                                @{Name="RoleName"; Expression={$roleName}},
                                @{Name="Object"; Expression={Get-Path $entityView}}
}