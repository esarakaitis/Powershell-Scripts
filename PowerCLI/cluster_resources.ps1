foreach ($cluster in get-cluster)
{
$clusterview = $cluster | get-view
$guestcount = $cluster | get-vm | measure-object
$respool = Get-View $clusterview.ResourcePool
$unreservedCpu = $respool.Summary.Runtime.Cpu.UnreservedForPool
$unreservedMem = $respool.Summary.Runtime.Memory.UnreservedForPool/1Mb
"" | select-object @{Name="Cluster"; Expression={$cluster.name}},
                   @{Name="VM's"; Expression={$guestcount.count}},
                   @{Name="Unreserved CPU (MHz)"; Expression={$unreservedCpu}},
                   @{Name="Unreserved Mem (Mb)"; Expression={$unreservedMem}}
}