$filename = “c:\results.csv”
$smtpServer = “cpsmail.ccs.local”
$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($filename)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = “from@email.com”
$msg.To.Add(”to@email.com”)
$msg.Subject = “Nightly Log File”
$msg.Body = “The nightly log file is attached”
$msg.Attachments.Add($att)
$smtp.Send($msg)