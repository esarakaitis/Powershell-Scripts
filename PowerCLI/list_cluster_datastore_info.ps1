#get list of clusters
$clusters = get-cluster
#for each cluster, get first vmhost
foreach ($cluster in $clusters)
{
    $vmhosts = $cluster | get-vmhost
    $firsthost = $vmhosts[0]
    $datastores = $firsthost | get-datastore | % {(Get-View $_.ID).summary}
    foreach ($datastore in $datastores)
    {
        $datastore | select-object @{Name = "Date"; Expression = {get-date}}, @{Name = "Cluster"; Expression = {$cluster.name}}, URL, Name, Freespace, Capacity
           }
        }