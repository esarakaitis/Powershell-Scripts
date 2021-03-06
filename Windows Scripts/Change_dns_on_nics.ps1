$servers = get-content C:\comp.txt
foreach($server in $servers)
{
Write-Host "Connect to $server..."
$nics = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Inquire | Where{$_.IPEnabled -eq "TRUE"}
$newDNS = "10.172.2.79","10.118.43.73"
foreach($nic in $nics)
{
Write-Host "`tExisting DNS Servers " $nic.DNSServerSearchOrder
$x = $nic.SetDNSServerSearchOrder($newDNS)
if($x.ReturnValue -eq 0)
{
Write-Host "`tSuccessfully Changed DNS Servers on " $server
}
else
{
Write-Host "`tFailed to Change DNS Servers on " $server
}
}
}