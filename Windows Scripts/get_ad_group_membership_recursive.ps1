if ((Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null)
{
	import-module ActiveDirectory
}

Get-ADGroupMember "ECE_Students" | ?{$_.ObjectClass -eq "Group"} | %{Write-Host $_.Name;Get-ADGroupMember $_ | ft name -HideTableHeaders}