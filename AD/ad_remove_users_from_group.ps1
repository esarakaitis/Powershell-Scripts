if ((Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null)
{
	import-module ActiveDirectory
}

$mymembers = Get-ADGroupMember -identity CCS_Attendance_Secretaries 

foreach($i in $mymembers)
	{
		Remove-ADGroupMember -Identity CCS_VDI_XD_USERS -Members $i
	}