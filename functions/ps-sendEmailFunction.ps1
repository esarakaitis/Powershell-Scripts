<#  
.SYNOPSIS  
	.Net send email as a powershell function.
.DESCRIPTION  
	This snippet can be used to send email from powershell script.
.NOTES  
    * it is important to note this is to be used on an open relay, otherwise 
	credentials need to be passed to the SMPT server for authorization.
	This script can be altered to accept parameters.  As is, must define variables
	and pass to function.
.LINK  
    http://msdn.microsoft.com/en-us/library/system.net.mail.smtpclient.aspx
.EXAMPLE  
	SendEmail $smtpServer $emailFrom $emailTo $emailSubject $emailBody
#>
function SendEmail($smtpServer, $emailFrom, $emailTo, $emailSubject, $emailBody)
{
	$smtpObj = new-object Net.Mail.SmtpClient($smtpServer)
	$smtpObj.Send($emailFrom, $emailTo, $emailSubject, $emailBody)
}

# pull in parameters
[STRING]$smtpServer = "" 		# param: smtp FQDN
[STRING]$emailSubject = ""		# param: email subject line
[STRING]$emailFrom = ""			# param: email from address
[STRING]$emailTo = ""			# param: email to address
[STRING]$emailBody = @"
"@								# param: email body - uses Here-String

# issue email
SendEmail $smtpServer $emailFrom $emailTo $emailSubject $emailBody
