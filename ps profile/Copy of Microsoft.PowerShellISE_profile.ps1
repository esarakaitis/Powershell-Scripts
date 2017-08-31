Add-PSSnapin VMware.VimAutomation.Core
add-pssnapin PshX-SAPIEN
. "C:\Program Files\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-VIToolkitEnvironment.ps1"
#aliases
set-alias grep select-string;
#functions
$viServers = @() 
$viServers += Connect-ViServer "vcprod02"-wa 0 
$viServers += Connect-ViServer "vcentsy01ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy02ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy03ewdu.oa.oclc.org"-wa 0
$viServers += Connect-ViServer "vcentsy01ewwe.oa.oclc.org"-wa 0
