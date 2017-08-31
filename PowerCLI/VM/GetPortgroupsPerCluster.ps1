foreach ($cluster in Get-Cluster) 
{ 
    # Make sure this is returned as an array. 
    $vmhosts = @($cluster | Get-VMHost) 
  
    if ($vmhosts.Length -eq 0) 
    { 
        # No vmhosts in this cluster, move on to the next one. 
        continue 
    } 
    
    $firstHost = $vmhosts[0] 
    
    foreach ($portgroup in ( $firstHost | Get-VirtualPortGroup)) 
    { 
        # Output results 
        "" | Select-Object @{Name="Cluster"; Expression={$cluster.Name}}, 
                           @{Name="vSwitch"; Expression={$portgroup.virtualswitchname}}, 
                           @{Name="Portgroup"; Expression={$portgroup.name}}, 
                           @{Name="Host"; Expression={$firstHost.name}} 
    } 
} 
