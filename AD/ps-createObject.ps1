<#
.SYNOPSIS
	Create an object in Powershell and load it with an array.
.DESCRIPTION
	This script is an example of how you can create objects in Powershell for
	formatting or more complex variable manipulation/capture.  This example uses
	the Get-Service cmdlet for input data.
.EXAMPLE
	.\ps-createObject
.NOTES

.LINK
	http://technet.microsoft.com/en-us/library/hh849885.aspx
#>
$outputArray = @()
$services = Get-Service | ?{$_.Status -eq "Running"}
foreach($service in $services){
	$data = @{Status=($service.Status);Name=($service.Name);DisplayName=($service.DisplayName);Timestamp=(Get-Date -f G)}
	$objData = New-Object PSObject -Property $data
	$outputArray += $objData
}
$outputArray | ft DisplayName,Name,Status,Timestamp -auto