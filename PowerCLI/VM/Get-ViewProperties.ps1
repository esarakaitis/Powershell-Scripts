function Get-ViewProperties {
	param($object, $prefix="")

	$ret = @()
	if (-not $object) {
		return $ret;
	}
	$properties = $object | gm | where { $_.MemberType -eq "Property" }
	foreach ($p in $properties) {
		if ($p.Name -eq "DynamicType" -or $p.Name -eq "DynamicProperty") {
			continue
		}

		if ($p.Definition -match "VMware.Vim.ManagedObjectReference") {
			# Do nothing. You could load the view to get nested references. Be aware though that
			# the object graph has loops in it (lots of them actually).
		} elseif ($p.Definition -match "VMware.Vim") {
			if ($object.($p.Name).value__ -ne $null) {
				$obj = new-object PSObject
				$obj | add-member -membertype noteproperty -name Name -value ($prefix + $p.Name)
				$obj | add-member -membertype noteproperty -name Value -value $object.($p.Name)
				$ret += $obj
			} else {
				$newPrefix = $prefix + $p.Name + "."
				$ret += Get-ViewProperties -object $object.($p.Name) -prefix $newPrefix
			}
		} else {
			if ($object.($p.Name) -ne $null) {
				$obj = new-object PSObject
				$obj | add-member -membertype noteproperty -name Name -value ($prefix + $p.Name)
				$obj | add-member -membertype noteproperty -name Value -value $object.($p.Name)
				$ret += $obj
			}
		}
	}

	return $ret
}
