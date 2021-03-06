$Col = @()
foreach ($cluster in Get-Cluster)
{
    $vmhosts = $cluster | Get-VMhost
    
    if (!$vmhosts) {continue}
    
    $firsthost = $vmhosts[0]
    $datastores = $firsthost | get-datastore | % {(Get-View $_.ID).summary}
    foreach ($datastore in $datastores)
    {
        $Col += $datastore | select-object 	@{Name = "Date"; Expression = {get-date}}, `
									@{Name = "Cluster"; Expression = {$cluster.name}}, `
									URL, Name, Freespace, Capacity
	}
}
$col | Export-Csv c:\cpuinfo.csv 