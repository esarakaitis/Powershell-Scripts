get-cluster "ENTINT01WE Cluster" | Get-VMHost | `
% {Get-View $_.ID} | `
% {$esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} | `
% {foreach($physnic in $_.NetworkInfo.Pnic){
		$pnicInfo = $_.QueryNetworkHint($physnic.Device)
		foreach($hint in $pnicInfo){
			Write-Host $esxname $physnic.Device
			$hint.connectedSwitchPort | Select * 
                        $hint.connectedSwitchPort.deviceCapability | Select *
		}
	}
}
