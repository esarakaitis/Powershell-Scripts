$vi_server = “vcenter01.net”
$vcuser = "root"
$vcpass = "vmware"
$communities = "idaho"
$syslocation = "Carthage"

Connect-VIServer -Server $vi_server -User $vcuser -Password $vcpass

# Setup variable to use in script for all hosts in vCenter
$vmhosts = @(Get-VMHost)

# Configure syslog on each host in vCenter
foreach ($vmhost in $vmhosts) {
Write-Host ‘$vmhost = ‘ $vmhost
$esxcli = Get-EsxCli -VMHost $vmhost
$esxcli.system.snmp.set($null,$communities,"true",$null,$null,$null,$null,$null,$null,$null,$null,$null,$syslocation)
$esxcli.system.snmp.get()
}

Disconnect-VIServer * -Confirm:$false