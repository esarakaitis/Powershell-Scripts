$viServers = @() 
#$viServers += Connect-ViServer "vctest01.dev.oclc.org" -wa 0
$viServers += Connect-ViServer "vcprod02"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy03ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy01ewwe.oa.oclc.org"-wa 0

foreach ($cluster in Get-Cluster -Server $viServers)
{
$guestcount = $cluster | get-vm | measure-object
$hostcount = $cluster | get-vmhost |  measure-object
"" | select-object @{Name="Cluster"; Expression={$cluster.name}},
                   @{Name="Hosts"; Expression={$hostcount.count}},
                   @{Name="VM's"; Expression={$guestcount.count}}
}
