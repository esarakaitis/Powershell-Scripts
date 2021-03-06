get-vmhost | Add-VMHostNtpServer -NtpServer "172.16.40.2"
get-vmhost | Add-VMHostNtpServer -NtpServer "172.16.40.3"
get-vmhost | Get-VmHostService | Where-Object {$_.key -eq “ntpd“} | Start-VMHostService
get-vmhost | Get-VmHostService | Where-Object {$_.key -eq “ntpd“} | set-VMHostService -Policy "Automatic"