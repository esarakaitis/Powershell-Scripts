function Get-InstanceMembers($class)
{
	New-Object $class | Get-Member
}