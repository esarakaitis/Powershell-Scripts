<#
.SYNOPSIS
	Listing of Powershell functions.
.DESCRIPTION
	Various functions which can be either include (copy/paste) into your script
	or referenced by including this script into script load.
.EXAMPLE
	# include
	. \\<UNC_PATH_TO_THIS_FILE>
.NOTES
	The last two work in conjuction, must include both in your script for proper use
.LINK
	
#>
function getObjects($objType,$objDN,$objName,$objScope){
	# function which accepts object type, distinguished name, display name and scope
	# of an object in AD and returns the object(s), performs LDAP query, usually faster
	# than cmdlets (i.e. Get-ADUser, GEt-QADUser
	$strFilter = "(&(objectClass=$objType)($objName))"
	$objDomain = New-Object System.DirectoryServices.DirectoryEntry($objDN)
	$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
	$objSearcher.SearchRoot = $objDomain
	$objSearcher.Filter = $strFilter
	$objSearcher.SearchScope = $objScope
	$objects = $objSearcher.findAll()
	return $objects
}
function newPrinterGPO($gpoName,$gpoComment){
	# creates a new policy in domain, uses GPO cmdlets (http://technet.microsoft.com/en-us/library/ee461027.aspx)
	$output = "New-GPO -Name $gpoName -comment $gpoComment"
	$output | out-file -filepath c:\printerGPOMapping.txt -append
}
function copyPrinterGPO($gpoGUID,$gpoName){
	# copies settings from a pre-existing GPO to a new GPO (http://technet.microsoft.com/en-us/library/ee461027.aspx)
	$output = "Copy-GPO -SourceGUID $gpoSrcGUID -TargetName $gpoTarName"
	$output | out-file -filepath c:\printerGPOMapping.txt -append
	
}
function linkPrinterGPO($prntPolName,$sitePath,$server){
	# this function links GPO's to organizational units (OU) (http://technet.microsoft.com/en-us/library/ee461027.aspx)
	# creates commands for you and outputs to file or runs from script
	$output = "New-GPLink -Name $prntPolName -Target $sitePath -LinkEnabled Yes -Server $server`n"
	$output | out-file -filepath c:\printerGPOMapping.txt -append
	# New-GPLink -Name $prntPolName -Target $sitePath -LinkEnabled Yes -Server $server -OutVariable logLinkCreation
	# $logLinkCreation | Out-File -filepath c:\logLinkCreation.txt -append
}
function addGPOPerms($gpoGUID,$targetName,$targetType,$permissions){
	# sets permissions on GPO's (http://technet.microsoft.com/en-us/library/ee461038.aspx) also requires
	# GPO cmdlets (see above)
	Set-GPPermissions -GUID $gpoGUID -TargetName $targetName -TargetType $targetType -PermissionLevel $premissions
}
function email($emailSubject, $emailBody, $emailAddressTo, $emailAddressFrom, $smtpServer){
	# accepts parameters for emailing with open relay
	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)
	$msg.From = $emailAddressFrom
	$msg.To.Add($emailAddressTo)
	$msg.Subject = $emailSubject
	$msg.Body = $emailBody
	$smtp.Send($msg)
}
function DrawMenu {
    ## support function to the Menu function below
    param ($menuItems, $menuPosition, $menuTitle)
    $fcolor = $host.UI.RawUI.ForegroundColor
    $bcolor = $host.UI.RawUI.BackgroundColor
    $l = $menuItems.length + 1
    cls
    $menuwidth = $menuTitle.length + 4
    Write-Host "`t" -NoNewLine
    Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine
    Write-Host "* $menuTitle *" -fore $fcolor -back $bcolor
    Write-Host "`t" -NoNewLine
    Write-Host ("*" * $menuwidth) -fore $fcolor -back $bcolor
    Write-Host ""
    Write-debug "L: $l MenuItems: $menuItems MenuPosition: $menuposition"
    for ($i = 0; $i -le $l;$i++) {
        Write-Host "`t" -NoNewLine
        if ($i -eq $menuPosition) {
            Write-Host "$($menuItems[$i])" -fore $bcolor -back $fcolor
        } else {
            Write-Host "$($menuItems[$i])" -fore $fcolor -back $bcolor
        }
    }
}
function Menu {
    ## Generate a small "DOS-like" menu.
    ## Choose a menuitem using up and down arrows, select by pressing ENTER
    param ([array]$menuItems, $menuTitle = "")
    $vkeycode = 0
    $pos = 0
    DrawMenu $menuItems $pos $menuTitle
    While ($vkeycode -ne 13) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $vkeycode = $press.virtualkeycode
        Write-host "$($press.character)" -NoNewLine
        If ($vkeycode -eq 38) {$pos--}
        If ($vkeycode -eq 40) {$pos++}
        if ($pos -lt 0) {$pos = 0}
        if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
        DrawMenu $menuItems $pos $menuTitle
    }
    Write-Output $($menuItems[$pos])
}