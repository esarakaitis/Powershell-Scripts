$comps = get-content c:\comp.txt
foreach ($comp in $comps)
	{
	$thisComp = get-adcomputer $comp
	Add-ADGroupMember "INH_200_Floor_Instructional_Computers" $thisComp
	}