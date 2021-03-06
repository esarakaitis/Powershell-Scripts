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
    
    $master_ds_list = @{}
    # Treat the first one as authoritative and create the master list.
    foreach ($datastore in ($vmhosts[0] | Get-Datastore))
    {
        $master_ds_list[$datastore.Name] = "Missing"
    }
    
    # Evaluate the hosts.  Process the first host again just to make sure
    # the report is complete.
    foreach ($vmhost in $vmhosts)
    {
        # Copy the master list
        $test_ds_list = @{} + $master_ds_list
        
        foreach ($ds in ($vmhost | Get-Datastore))
        {
            # If the datastore is in the test list it is ok.
            # Otherwise it is extra.
            if ($test_ds_list.ContainsKey($ds.name))
            {
                $test_ds_list[$ds.name] = "Ok"
            }
            else
            {
                $test_ds_list[$ds.name] = "Extra"
            }
        }
        
        # Output results
        foreach ($key in $test_ds_list.Keys)
        {
            $key | Select-Object @{Name="Cluster"; Expression={$cluster.Name}}, `
                                 @{Name="Host"; Expression={$vmhost}}, `
                                 @{Name="Datastore"; Expression={$_}},
                                 @{Name="Status"; Expression={$test_ds_list[$_]}}
        }
    }
}