foreach ($vmhost in get-vmhost) {
$HostView = Get-View $vmhost.ID
$NetworkSystem = get-view $HostView.ConfigManager.NetworkSystem
$AllPortGroups = $NetworkSystem.NetworkInfo.Portgroup | where {$_.Spec.VlanId -gt 0 }
foreach ($HostPortGroup in $AllPortGroups){
"" | select @{Name = "Name"; Expression = {$vmhost.name}}, @{Name = "VLAN"; Expression = {$HostPortGroup.Spec.Name}}
}
}