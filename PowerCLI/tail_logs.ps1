$esx = Get-Cluster "target-cluster" | Get-VMHost
$esx | %{
	$esxlog = Get-Log -Key "vmkernel" -VMHost $_
	$nrEntries = $esxlog.Entries.Count
	Write-Host $_.Name -foregroundcolor green
	$esxlog.Entries[($nrEntries-11)..($nrEntries-1)]
}