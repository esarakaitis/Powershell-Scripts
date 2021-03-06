$viServers = @() 
$viServers += Connect-ViServer "vcprod02.dev.oclc.org"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy01ewwe.oa.oclc.org"-wa 0

foreach ($vc in $viServers) 
    {
        Get-Datastore -Server  $vc | Select Name, @{N="NumVM";E={@($_ | Get-VM).Count}} | Sort Name
    }