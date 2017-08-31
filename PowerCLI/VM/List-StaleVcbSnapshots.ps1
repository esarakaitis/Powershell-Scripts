#<author>Eric Wannemacher</author>
#<version>1</version>
#<description>Locate and alert on stale VCB backups</description>

Param
(
	[Int]$days = 1, # Threshold to determine staleness
	[switch]$emailreport # Email a report
)

$today = Get-Date
$cutoff = $today.AddDays(0 - $days)
$info_message = "Stale VCB snapshots as of {0}" -f $today

# Email Settings
$email_to = "s192484@aep.com"
$email_from = New-Object Net.Mail.MailAddress("donotreply@aep.com", "VMware Infrastructure Monitor")
$smtp_server = "mailmta.aepsc.com"
$smtp_server_port = 2525

[void](Connect-VIServer virtualcenter2)

$stale_snapshots = Get-Cluster "Arena" | Get-VM | ForEach-Object { `
	$vm = $_
	$vm | Get-Snapshot | `
	Where-Object {$_.Name -eq "_VCB-BACKUP_" -and $_.Created -lt $cutoff} | `
	Select-Object @{Name="VM"; Expression={$vm}}, Created
}

if ($emailreport) 
{ 
	$html_page = "<html><head><title>$info_message</title></head><body>`n<table><tr align=`"left`"><th>VM Name</th><th>Snapshot Date</th></tr>"
	
	foreach ($snapinfo in $stale_snapshots)
	{
		$html_page += "<tr><td>{0}</td><td>{1}</td></tr>`n" -f $snapinfo.VM, $snapinfo.Created
	}
	
	$html_page += "</table></body></html>"

	$msg = New-Object System.Net.Mail.MailMessage
	$msg.From = $email_from
	foreach ($address in $email_to) {$msg.To.Add($address)}
	$msg.Subject = $info_message
	$msg.Body = $html_page
	$html_view = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($msg.Body, "text/html")
	$msg.AlternateViews.Add($html_view)
	
	$smtp_client = New-Object System.Net.Mail.SmtpClient
	$smtp_client.Host = $smtp_server
	$smtp_client.Port = $smtp_server_port
	$smtp_client.Send($msg)
	
	Write-Output $html_page > "test.html"
}

$stale_snapshots

[void](Disconnect-VIServer -confirm:$false)