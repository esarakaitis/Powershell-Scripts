foreach ($arg in $args)
{
	Get-VMHost $arg | Get-VMHostService | Where {$_.key -eq "vmware-vpxa"} |Restart-VMHostService -Confirm:$false
}