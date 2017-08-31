<#
.SYNOPSIS
	Verify user UPNs match email address of user account.
.DESCRIPTION
	Verify user UPNs match email address; new suffix compared to old suffix.
	Takes 
.EXAMPLE
	.\ps-verifyUPNtoEmail.ps1 -searchRoot <DN_TO_SEARCH_ROOT> -dcName <DC_NAME_OR_FQDN> -filePath <FILE_NAME_PATH>
.NOTES
	*** REQUIRES QUEST ACTIVE DIRECTORY CMDLETS ***
.LINK
	http://wiki.powergui.org/index.php/Get-QADUser
#>
PARAM([STRING]$searchRoot,[STRING]$dcName,[STRING]$filePath = "c:\errUser.txt")
$errUser = @()
Connect-QADService $dcName
$users = Get-QADUser -SearchRoot $searchRoot -SearchScope subtree -SizeLimit 0
foreach($user in $users){
		# can use user object to display any user attribute, if attib not
		# found add -includeallproperties to $user variable assignment statement
	$email = $user.Email
	$upn = $user.UserPrincipalName
	if($email -AND $email -Match $upn){}else{$errUser += "$upn`t$email"}
}
# $errUser
$errUser | Out-File -FilePath -Append
