$info ={(Get-View $_.ID).config.network.dnsconfig}
get-vmhost | % $info | select HostName