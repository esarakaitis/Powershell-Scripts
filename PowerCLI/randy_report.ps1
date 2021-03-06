foreach ($cluster in get-cluster)
{
$meminfo = $cluster | get-vm | measure-object -property memorymb -sum
$hostcount = $cluster | get-vmhost |  measure-object
    "" | select-object @{Name="Cluster"; Expression={$cluster.name}},
                       @{Name="Hosts"; Expression={$hostcount.count}},
                       @{Name="Num VM's"; Expression={$meminfo.count}},
                       @{Name="Mem Allocation"; Expression={$meminfo.Sum}}
 }  
 