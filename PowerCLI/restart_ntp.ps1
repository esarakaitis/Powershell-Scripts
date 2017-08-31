foreach ($vmhost in get-vmhost)
{
Get-VmHostService -VMHost $vmhost | Where-Object {$_.key -eq "ntpd"} | Restart-VMHostService -Confirm:$false
}