
$vmhosts = @(get-cluster | Get-VMHost)

foreach ($vmhost in $vmhosts) {
	write-host "Configuring SSH on host: $($vmHost.Name)" -fore Yellow
    if((Get-VMHostService -VMHost $vmHost | where {$_.Key -eq "TSM-SSH"}).Policy -ne "on"){
        Write-Host "Setting SSH service policy to automatic on $($vmHost.Name)"
        Get-VMHostService -VMHost $vmHost | where { $_.key -eq "TSM-SSH" } | Set-VMHostService -Policy "On" -Confirm:$false -ea 1 | Out-null
	}
	if((Get-VMHostService -VMHost $vmHost | where {$_.Key -eq "TSM-SSH"}).Running -ne $true){
        Write-Host "Starting SSH service on $($vmHost.Name)"
        Start-VMHostService -HostService (Get-VMHost $vmHost | Get-VMHostService | Where { $_.Key -eq "TSM-SSH"}) | Out-null
    }
	$esxcli = Get-EsxCli -VMHost $vmhost
	if($esxcli -ne $null){

		if(($esxcli.network.firewall.ruleset.allowedip.list("sshServer") | select AllowedIPAddresses).AllowedIPAddresses -ne "All"){
        	Write-Host "Changing the sshServer firewall configuration"        
        		$esxcli.network.firewall.ruleset.set($true, $true, "sshServer")
            	$esxcli.network.firewall.refresh()
        }
		# End Comment
		if(($vmHost | Get-AdvancedSetting | Where {$_.Name -eq "UserVars.SuppressShellWarning"}).Value -ne "1"){
        	Write-Host "Suppress the SSH warning message"
        		$vmHost | Get-AdvancedSetting | Where {$_.Name -eq "UserVars.SuppressShellWarning"} | Set-AdvancedSetting -Value "1" -Confirm:$false | Out-null
    	}
}
}