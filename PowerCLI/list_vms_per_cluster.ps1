$clusters = get-cluster

foreach ($cluster in $clusters)
{
    foreach ($vmhost in ($cluster | get-vmhost))
    {
        $vmhost | get-vm | Select-Object @{Name="Cluster"; Expression={$cluster.name}},`
            Name
    }
}