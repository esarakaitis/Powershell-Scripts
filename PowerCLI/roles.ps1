$si = Get-View ServiceInstance
$am = Get-View $si.Content.AuthorizationManager


$am.RoleList | % {
 $_.Name
 $_.Privilege | Sort | % { "`t" + $_ }
}