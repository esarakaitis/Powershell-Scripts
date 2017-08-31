foreach ($cluster in Get-Cluster)
{
    foreach ($vm in ($cluster | Get-VM))
    {
        $vm | Select-Object @{Name="Cluster"; Expression={$cluster.name}},
                            @{Name="Host"; Expression={$vm.host.name}},
                            @{Name="VM"; Expression={$vm.name}}
    }
}