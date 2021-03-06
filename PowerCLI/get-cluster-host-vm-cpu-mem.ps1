$viServers = @() 

$viServers += Connect-ViServer "vcprod02"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy03ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy01ewwe.oa.oclc.org"-wa 0
$report = @()
foreach ($cluster in Get-Cluster -Server $viServers)
{
$clusterview = $cluster | get-view
$guestcount = $cluster | get-vm | measure-object
$hostcount = $cluster | get-vmhost |  measure-object

$report += "" | select-object @{Name="Cluster"; Expression={$cluster.name}},
                   @{Name="Hosts"; Expression={$hostcount.count}},
                   @{Name="VM's"; Expression={$guestcount.count}},
                   @{Name="Total CPU GHZ"; Expression={$clusterview.summary.totalcpu}},
                   @{Name="Total Memory in Bytes"; Expression={$clusterview.summary.totalmemory}}
                   
}
$report | export-csv c:\1.csv