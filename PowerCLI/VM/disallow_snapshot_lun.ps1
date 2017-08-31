Get-VMHost -State "Connected" | %{
    $vmHost = $_ | Get-View
	$optmgrMoRef = $vmHost.configManager.advancedOption
	$optmgr = Get-View -Id $optmgrMoRef 
	$optarray = $optmgr.QueryOptions("LVM.DisallowSnapshotLun")

	$optarray[0].Value = 0
	$optmgr.UpdateOptions($optarray)
}