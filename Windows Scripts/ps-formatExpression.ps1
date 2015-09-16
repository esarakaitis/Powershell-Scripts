<#
.SYNOPSIS
	Formatting using expressions
.DESCRIPTION
	Used to build a format string which includes both expressions
	and labels then insert data.
.EXAMPLE
	Example uses the Get-Process cmdlet
.NOTES
	E = Expression, L = Label
.LINK
	
#>
$a = @{E={$_.Name};L="Process Name";width=25}, `
	@{E={$_.ID};L="Process ID";width=15}, `
	@{E={$_.MainWindowTitle};L="Window Title";width=40}
Get-Process | ft $a -auto