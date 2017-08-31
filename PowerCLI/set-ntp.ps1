$HS = Get-VMHost | get-view
$dtsystem =  $HS.ConfigManager.DateTimeSystem 
$mor = Get-View  $dtsystem
$dateConfig = New-Object Vmware.Vim.HostDateTimeConfig 
$hsntpConfig = New-Object VMware.Vim.HostNtpConfig 
$dateConfig.ntpConfig = $hsntpConfig 
$dateConfig.ntpConfig.server = @("ntp1.aepsc.com") 
$dateConfig.timeZone = "America/New_York"
$mor.updateDateTimeConfig($dateConfig)
