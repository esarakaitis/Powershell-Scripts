#load vmware environment
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\master.ps1"
$esx = Get-VMHost $ARGS[0] | Get-View
$ns = Get-View -Id $esx.configManager.networkSystem
$dns = $ns.networkConfig.dnsConfig
$dns.domainname = "aepsc.com"
$ns.UpdateDnsConfig($dns)