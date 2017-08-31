Param ($Source, $Target)
If ($Source -ne $Null -and $Target -eq $Null)
{
    $Target = Read-Host "Enter logon name of target user"
}
If ($Source -eq $Null)
{
    $Source = Read-Host "Enter logon name of source user"
    $Target = Read-Host "Enter logon name of target user"
}

# Retrieve group memberships.
$SourceUser = Get-ADUser $Source -Properties memberOf
$TargetUser = Get-ADUser $Target -Properties memberOf

# Hash table of source user groups.
$List = @{}

#Enumerate direct group memberships of source user.
ForEach ($SourceDN In $SourceUser.memberOf)
{
    # Add this group to hash table.
    $List.Add($SourceDN, $True)
    # Bind to group object.
    $SourceGroup = [ADSI]"LDAP://$SourceDN"
    # Check if target user is already a member of this group.
    If ($SourceGroup.IsMember("LDAP://" + $TargetUser.distinguishedName) -eq $False)
    {
        # Add the target user to this group.
        Add-ADGroupMember -Identity $SourceDN -Members $Target
    }
}

# Enumerate direct group memberships of target user.
ForEach ($TargetDN In $TargetUser.memberOf)
{
    # Check if source user is a member of this group.
    If ($List.ContainsKey($TargetDN) -eq $False)
    {
        # Source user not a member of this group.
        # Remove target user from this group.
        Remove-ADGroupMember $TargetDN $Target
    }
}