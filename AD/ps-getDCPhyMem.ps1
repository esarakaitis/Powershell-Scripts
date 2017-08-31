<#
.SYNOPSIS
	Find physical memory on domain controllers.
.DESCRIPTION
	Enumerates all DC's in a domain and then performs a WMI call against 
	physical memory outputting to console.
.EXAMPLE
	
.NOTES

.LINK
	
#>
$myDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$dcArray = $myDomain.DomainControllers
Write-Host
foreach($dc in $dcArray){
	$memCap = GWMI -Class WIN32_ComputerSystem -ComputerName $dc
	$memCap | %{$total += $_.totalPhysicalMemory}
	$total = [system.MATH]::ROUND($total/1GB)
	Write-Host "$dc`: $total`GB"
	$total = $NULL
}
Write-Host