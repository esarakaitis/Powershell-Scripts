$a = "<style>"
$a = $a + "BODY{background-color:white;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:palegoldenrod}"
$a = $a + "</style>"
$viServers = @() 
#$viServers += Connect-ViServer "vctest01.dev.oclc.org" -wa 0
$viServers += Connect-ViServer "vcprod02"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$report = @()
$clusters = get-cluster -Server $viServers 

foreach ($cluster in $clusters)
{
    foreach ($vmhost in ($cluster | get-vmhost))
    {
      $report += $vmhost | get-vm | Select-Object @{Name="Cluster"; Expression={$cluster.name}},`
            Name 
    }
}
$report | ConvertTo-HTML -head $a | Out-File C:\Inetpub\wwwroot\index.html