#$hostview = Get-View -Server "$global:defaultviserver" -ViewType HostSystem
#$hostview | %{$hostname = $_.Name; $_.Config.Network.Pnic} | %{
#	if($_.LinkSpeed -eq $null){
#		Write-Host "$hostname = $($_.Device) Link down"
#	}
#}

$hostlist = Get-View -Server "$global:defaultviserver" -ViewType HostSystem
if ((($hostlist | Measure-Object).Count) -gt 0) {
    ForEach ($VMHost in $hostlist) {
        ForEach ($PNIC in $VMHost.Config.Network.Pnic) {
            if ($PNIC.LinkSpeed -eq $null){
                Write-Host "$($VMHost.Name) = $($PNIC.Device) Link down"
            }
        }
    }
}