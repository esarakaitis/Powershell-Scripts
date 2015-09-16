$mymembers = Get-ADGroupMember -identity ccs_all_school_staff

foreach($i in $mymembers)
	{
		$submembers = get-adgroupmember -identity $i
		foreach($submember in $submembers)
		{
			Add-ADGroupMember -Identity CCS_VDI_XD_USERS  -Members $submember
		}
	}