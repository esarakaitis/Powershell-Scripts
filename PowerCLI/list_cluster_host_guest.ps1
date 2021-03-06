$clusters = get-cluster

foreach ($cluster in $clusters)
{
    foreach ($vmhost in ($cluster | get-vmhost))
    {
        $vmhost | get-vm | Select-Object @{Name="cluster"; Expression={$cluster.name}}, @{Name="host"; Expression={$vmhost.name}},`
            Name
    }
}