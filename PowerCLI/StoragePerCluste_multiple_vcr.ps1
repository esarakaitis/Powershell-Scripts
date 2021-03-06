$viServers = @() 
$viServers += Connect-ViServer "vcprod02.dev.oclc.org"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy01ewwe.oa.oclc.org"-wa 0
 
$Col = @()
 
foreach ($vc in $viServers) 
{ 
    foreach ($cluster in Get-Cluster -Server $vc)
    {
        $vmhosts = @($cluster | Get-VMhost)
        
        if (!$vmhosts) {continue}
        
        $firsthost = $vmhosts[0]       
       
        $datastores = $firsthost | Get-Datastore
        foreach ($datastore in $datastores)
        {
            $Col += $datastore | select-object @{Name = "vCenter"; Expression = {$vc.name}}, 
                                               @{Name = "Cluster"; Expression = {$cluster.name}},
                                               Name, FreespaceMB, CapacityMB
        }
    }
}
 
$col
$col | Export-Csv c:\storage.csv
 
Disconnect-Viserver -Confirm:$false