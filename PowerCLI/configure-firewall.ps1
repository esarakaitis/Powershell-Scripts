$esxhost = Get-VMHost
$esx = Get-View $esxhost.ID
$fwinfo = $esx.ConfigManager.FirewallSystem
$fw = Get-View $fwinfo
 $NTPRule=$fw.FirewallInfo.Ruleset | Where-Object {$_.Key -eq "ntpClient"}
  if ($NTPRule.Enabled -ne $True) {
    "Opening NTP firewall port"
    $fw.EnableRuleset("ntpClient")
    }
  else {
    "NTP port already open"
    }