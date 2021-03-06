foreach ($vmhost in get-cluster | get-vmhost)
{
$meminfo = $vmhost | get-vm | measure-object -property memorymb -sum
$guestcount = $vmhost | get-vm |  measure-object
    "" | select-object @{Name="Host"; Expression={$vmhost.name}},
                       @{Name="Num VM's"; Expression={$guestcount.count}},
                       @{Name="Mem Allocation"; Expression={$meminfo.Sum}}
 }  