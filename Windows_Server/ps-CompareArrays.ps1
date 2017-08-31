<#
.SYNOPSIS
	Compares array objects.
.DESCRIPTION
	This script compares arrays and reports matching and unmatching elements
	into two seperate files.
.EXAMPLE
	.\ps-CompareArrays.ps1
.NOTES
	You can recieve arrays from any method.
.LINK
	http://technet.microsoft.com/en-us/library/ee156812.aspx
#>
$arrFirst = @("one","Two","Three","Four","Five")
$arrSecond = @("three","Four","Five","Six","Seven")

New-Item "C:\FirstInSecond.txt" -Type file
New-Item "C:\FirstNotInSecond.txt" -Type file

Foreach ($First in $arrFirst)
{
	If ($arrSecond -contains $First)
	{Add-content "C:\FirstInsecond.txt" $First}
	Else
	{Add-content "C:\FirstNotInSecond.txt" $First}
}