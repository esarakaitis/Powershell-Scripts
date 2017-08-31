#Usage ./2012_configure_snmp.ps1 -ro ro123123 -rw rw123433 -ips 10.0.0.1,10.0.0.2,10.124.1.3
param (
    [string]$ro,
    [string]$rw,
    [string[]]$ips,
    [string]$location
 )

#$sysLocation = $location
Start-Transcript -path C:\windows\temp\snmp_output.txt -append
$managers = $ips

$sysContact = "EMSC eNOC"

#Configure SNMP Regigstry Keys
        Write-Host "Setting SNMP sysServices"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysServices /t REG_DWORD /d 79 /f | Out-Null
        Write-Host "Setting SNMP sysLocation"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysLocation /t REG_SZ /d $Location /f | Out-Null
        Write-Host "Setting SNMP sysContact"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent" /v sysContact /t REG_SZ /d $sysContact /f | Out-Null
        Write-Host "Setting SNMP Community Regkey"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration" /f | Out-Null
        Write-Host "Setting read only SNMP Community Regkey"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\$ro" /f | Out-Null
        Write-Host "Setting read write SNMP Community Regkey"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\$rw" /f | Out-Null
        Write-Host "Adding readonly SNMP Trap Communities"
#Loop Through Read Only SNMP Communities
        Write-Host "Adding readonly SNMP Trap Communities"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $ro /t REG_DWORD /d 4 /f | Out-Null
#Loop Through RW SNMP Communities
        Write-Host "Adding read wrtie SNMP Trap Communities"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $rw /t REG_DWORD /d 8 /f | Out-Null
        Write-Host "Creating SNMP Extension Agents RegKey"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ExtensionAgents" /f | Out-Null
        Write-Host "Creating SNMP SNMP Service Parameters RegKey"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters" /v NameResolutionRetries /t REG_DWORD /d 10 /f | Out-Null
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters" /v EnableAuthenticationTraps /t REG_DWORD /d 0 /f | Out-Null
#Loop through permitted SNMP management systems
        Write-Host "Adding Permitted Managers"
        $i = 1
        Foreach ($Manager in $Managers){
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $i /t REG_SZ /d $manager /f | Out-Null
            reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /v $i /t REG_SZ /d $manager /f | Out-Null
            $i++
        }
stop-transcript