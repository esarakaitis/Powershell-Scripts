foreach ($esxi in get-vmhost)
{
Remove-VirtualSwitch -VirtualSwitch (Get-VirtualSwitch -VMHost $esxi | where {$_.Name -eq "vSwitch0"}) -Confirm:$false
}