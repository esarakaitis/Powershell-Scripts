Import-Module activedirectory

function Get-Computers-From-OU ($orgunit) {
    $computers = @()
    $ou = [ADSI]"LDAP://$orgunit"
    foreach ($child in $ou.psbase.Children) {
        if ($child.objectCategory -like "*computer*") {
            $computers += $child
        } elseif ($child.objectCategory -like "*organizational-unit*") {
            $computers += Get-Computers-From-OU $child.distinguishedName
        }
    }
    
    return $computers
}

function Get-LocalGroupMembers ([string]$localcomputername, [string]$localgroupname) { 
    $groupobj =[ADSI]"WinNT://$localcomputername/$localgroupname" 
    $localmembers = @($groupobj.psbase.Invoke("Members")) 
    $localmembers | foreach {$_.GetType().InvokeMember("AdsPath","GetProperty",$null,$_,$null)}
} 


