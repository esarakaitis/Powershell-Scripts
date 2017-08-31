$vswitchname = "vSwitch2"
$esxImpl = Get-VMHost -Name (get-vmhost)
$esx = $esxImpl | Get-View
$ns = Get-View -Id $esx.ConfigManager.NetworkSystem
 foreach($sw in $esx.Config.Network.Vswitch){
  if($sw.Name -eq $VSwitchName){break}
}
 $vsSpec = $sw.Spec
$vsSpec.Policy.NicTeaming.Policy = "loadbalance_srcmac"
$vsSpec.Policy.Security.AllowPromiscuous = $true
 $ns.UpdateVirtualSwitch($VSwitchName,$vsSpec)