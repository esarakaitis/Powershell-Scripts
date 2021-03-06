# For each cluster.
foreach ($cluster in Get-Cluster)
{
    # Get the hosts.
    $vmhosts = $cluster | Get-VMHost

    # Skip to the next cluster if there were no hosts defined.
    if (!$vmhosts)
    {
        continue
    }
    
    $master_pg_list = @{}
    # Treat the first one as authoritative and create the master list.
    foreach ($portgroup in ($vmhosts[0] | Get-VirtualPortGroup))
    {
        $master_pg_list[$portgroup.Name] = "Missing"
    }
    
    # Evaluate the hosts.  Process the first host again just to make sure
    # the report is complete.
    foreach ($vmhost in $vmhosts)
    {
        # Copy the master list
        $test_pg_list = @{} + $master_pg_list
        
        foreach ($pg in ($vmhost | Get-VirtualPortGroup))
        {
            # If the portgroup is in the test list it is ok.
            # Otherwise it is extra.
            if ($test_pg_list.ContainsKey($pg.name))
            {
                $test_pg_list[$pg.name] = "Ok"
            }
            else
            {
                $test_pg_list[$pg.name] = "Extra"
            }
        }
        
        # Output results
        foreach ($key in $test_pg_list.Keys)
        {
            $key | Select-Object @{Name="Cluster"; Expression={$cluster.Name}}, `
                                 @{Name="Host"; Expression={$vmhost}}, `
                                 @{Name="Portgroup"; Expression={$_}},
                                 @{Name="Status"; Expression={$test_pg_list[$_]}}
        }
    }
}