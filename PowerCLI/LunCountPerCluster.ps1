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
    
    foreach ($scsilun in ($firstHost | get-scsilun | ? {$_.Vendor -notlike "*Dell*"} | measure-object)) 
    { 
        # Output results 
        "" | select  @{Name = "Cluster"; Expression = {$cluster.name}},@{Name = "Host"; Expression = {$firsthost.name}}, @{Name = "NumLunz"; Expression = {$scsilun.count}}
    } 
} 
