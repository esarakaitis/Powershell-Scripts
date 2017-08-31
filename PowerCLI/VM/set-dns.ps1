$esx = Get-VMHost ohaephqvm003.aepsc.com | Get-View
$ns = Get-View -Id $esx.configManager.networkSystem
$dns = $ns.networkConfig.dnsConfig
$dns.domainname = "aepsc.com"
$ns.UpdateDnsConfig($dns)