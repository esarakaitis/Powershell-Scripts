Import-Module ActiveDirectory 
$BIOUList ="" 
$BIOUList = get-adorganizationalUnit -LDAPFilter '(gpOptions=1)' 
$BIOUList | FT Name 

Get the list of users in the list of OUs using this command: 
Foreach ($OU in $BIOUList) { get-aduser -filter * -searchbase $OU.distinguishedname |FT SamAccountName,Name}