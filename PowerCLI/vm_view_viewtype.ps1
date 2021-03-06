$clusterHosts = Get-View -ViewType ClusterComputeResource -Filter @{"Name"="ENTPRF03"} | Select-Object -ExpandProperty Host | Select-Object -ExpandProperty Value

$clusterHostsCount = $clusterHosts.length
$vmHostLoopCount = 0

$vmHostList = ""

foreach ($vmHost in $clusterHosts) {
    $vmHostLoopCount++
    $vmHostList += "^"+$vmHost+"$"
    if ($vmHostLoopCount -lt $clusterHostsCount) {
        $vmHostList += "|"
    }
}

$vmGuestList = Get-View -ViewType VirtualMachine -Filter @{"Runtime.Host"="$vmHostList"}
$vmGuestList | Select-Object -ExpandProperty Guest
