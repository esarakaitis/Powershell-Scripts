$myCol = @()
ForEach ($Cluster in Get-Cluster)
    {
        ForEach ($vmhost in ($cluster | Get-VMHost))
        {
            $VMView = $VMhost | Get-View
                        $VMSummary = “” | Select HostName, ClusterName
                        $VMSummary.HostName = $VMhost.Name
                        $VMSummary.ClusterName = $Cluster.Name
                        $myCol += $VMSummary
                    }
            }
$myCol | export-csv c:\1.csv