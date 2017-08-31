$OutfilePath = "C:\users\user\desktop\ESXiHostsandIQNs.csv"
$ESXiHosts = Get-VMHost | Sort-Object
$ESXIQN = @{}

#Pull IQNs from each Host within VCenter
foreach ($ESXiHost in $ESXiHosts) {

    $VMHost = Get-VMhost $ESXiHost.Name

    $hostview = Get-View $VMHost.id
    $storage = Get-View $hostview.ConfigManager.StorageSystem
 
    $ESXName = $VMHost.Name
    $IQN = $storage.StorageDeviceInfo.HostBusAdapter.iScsiName

    $ESXIQN.Add($ESXName, $IQN)
}

#Export loop hashtable to CSV
foreach ($ESXEntry in $ESXIQN.GetEnumerator()) {
    $ESXEntry | select Name, Value | export-csv $OutfilePath -NoTypeInformation -Append
}