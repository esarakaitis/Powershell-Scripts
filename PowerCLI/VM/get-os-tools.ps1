$viServers = @() 
$viServers += Connect-ViServer "vcprod02.dev.oclc.org"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy01ewwe.oa.oclc.org"-wa 0
get-vm -Server $viServers | % { get-view $_.ID } | select Name, @{ Name="ToolsStatus"; Expression={$_.guest.toolsstatus}}, @{ Name="ToolsVersion"; Expression={$_.config.tools.toolsVersion}}, @{ Name="OS"; Expression={$_.config.guestfullname}}