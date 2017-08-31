foreach ($vmhost in Get-VMHost)
	{
	$hostview = Get-View $vmhost.ID
	$ns = Get-View -Id $hostview.ConfigManager.NetworkSystem

			foreach($sw in $hostview.Config.Network.Vswitch)
			{
			$vsSpec = $sw.Spec
			$vsSpec.Policy.Security.AllowPromiscuous = $false
			$vsSpec.Policy.Security.ForgedTransmits = $false
			$vsSpec.Policy.Security.MacChanges = $false
			$ns.UpdateVirtualSwitch($sw.Name, $vsSpec)
			}
	}
