#equivalent to get-vmhost | get-view
$hostview = Get-View -Server "$global:defaultviservers" -ViewType HostSystem
#equivalent to get-vm | get-view
$vmview = Get-View -Server "$global:defaultviservers" -ViewType VirtualMachine
#EOF