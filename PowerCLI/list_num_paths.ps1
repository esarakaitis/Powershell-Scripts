$report = @()
Get-VMHost | %{
  $EsxName = $_.Name
  $ds = ($_ | Get-View).Datastore | %{get-view -Id $_} | where {$_.Summary.Type -eq "VMFS"}
  $luns = $_ | Get-ScsiLun
  $luns | %{ 
    $lun = $_.CanonicalName
    $nrPath = ($_ | Get-ScsiLunPath | Measure-Object).Count
	$dsName = ($ds | where {$_.Info.Vmfs.Extent[0].DiskName -eq $lun}).Info.Name
	$row = "" | Select EsxName, dsName, lun, nrPath
	$row.ESXname = $EsxName
	$row.dsName = $dsName
	$row.lun = $lun
	$row.nrPath = $nrPath
	$report += $row
  }
}  
$report
