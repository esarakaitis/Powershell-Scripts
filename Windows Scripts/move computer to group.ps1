$pcs= Get-ADComputer -LDAPFilter "(name=sue*)" -SearchBase "ou=thick,ou=3_workstations,DC=ccs,DC=local"
foreach ($pc in $pcs) 
    {
   Add-ADGroupMember "FHH_WSUS_WKS" $pc
    }