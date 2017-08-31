$viServers = @() 
#$viServers += Connect-ViServer "vctest01.dev.oclc.org" -wa 0
$viServers += Connect-ViServer "vcprod02"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0

