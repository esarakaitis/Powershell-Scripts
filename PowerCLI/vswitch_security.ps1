foreach ($vmhost in get-vmhost){
    $hostview = Get-View $vmhost.ID
	$portgroups = $hostview.Config.network.portgroup
    foreach ($portgroup in $portgroups)
    {
		  $portgroup | select @{Name="Host"; Expression={$vmhost.Name}},
                              @{Name="PortGroup Name"; Expression={$portgroup.spec.Name}},
                              @{Name="VSwitch Name"; Expression={$portgroup.spec.vswitchname}},
                              @{Name="Beacon Probing Enabled"; Expression={$portgroup.spec.policy.nicteaming.failurecriteria.checkbeacon}}
    }
}