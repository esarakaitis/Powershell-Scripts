$servers = 'ccs717wvzdc01', 'ccs717wvzdc01','ccs717wvdc5','ccs717wvdc4','ccs717wvdb2','ccs717wvdb3','ccs717wvdb1','ccs717wvddc01','ccs717wvddc02','ccs717xamon01','ccs717wvvc2','ccs717wvwi01','ccs717wvwi02','ccs717wvav4','ccs717wvxapvs01','ccs717wvxapvs02','ccs717wvxdpvs01','ccs717wvxdpvs02'
foreach ($server in $servers)
{

psexec \\"$server" -s -d powershell "\\ccs717wvdc4\NETLOGON\SNMP\install.ps1"
} 