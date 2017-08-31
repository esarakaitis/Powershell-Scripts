#load vmware environment
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\master.ps1"
$nics = (get-vmhost $ARGS[0] | get-vmhostnetwork).PhysicalNic
$nics | where { $_.DeviceName -eq "NIC_TO_CONFIGURE" } | Set-VMHostNetworkAdapter -duplex full -bitratepersecmb 1000