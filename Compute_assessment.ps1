
$ClusterName = ''

#region Get List of Hosts
if ($ClusterName)
{
	$VMHosts = Get-Cluster -Name $ClusterName | Get-VMHost | Where-Object { $_.ConnectionState -eq "Connected" }
}
else
{
	$VMhosts = Get-VMHost | Where-Object { $_.ConnectionState -eq "Connected" }
}
#endregion Get List of Hosts
 
$results = @()
$arrteampol = @()
 
#region Loop thru hosts
foreach ($VMHost in $VMHosts)
{

	$arrNicDetail = @()
    $arrHBADetail = @()
    $arrPathDetail = @()

    #Get View info
	$esxcli = Get-VMHost $VMHost | Get-EsxCli
    $hostview = Get-View -ViewType HostSystem -Property Name,Config.StorageDevice,Hardware -Filter @{"Name" = $VMHost.Name}
    $hostbios = $hostview.Hardware.BiosInfo.BiosVersion
    $clustername = $VMHost.Parent
    $hostname = $VMHost.Name

	#Get list of NICs on host
	$VMHostNetworkAdapters = Get-VMHost $VMHost | Get-VMHostNetworkAdapter | Where-Object { $_.Name -like "vmnic*" }
    $ntpstatus = Get-VMHost $VMHost | Get-VMHostService | Where-Object {$_.key -eq "ntpd"} | select Running


    Write-Host "Checking" $VMHost.Name
    #region get vSwitch info

    #First get vDS info
    $vDS = Get-VDSwitch -VMHost $VMHost
    if ($vDS) 
    {
        $objvDSPGs = Get-VDPortgroup -VDSwitch $vDS | where {$_.Name -notlike "*DVUplinks*"}

        foreach ($portgroup in $objvDSPGs)
        {
            $vdsteampol = Get-VDPortgroup $portgroup | Get-VDUplinkTeamingPolicy | Select-Object VDPortgroup,ActiveUplinkPort,StandbyUplinkPort,EnableFailback,UnusedUplinkPort,LoadBalancingPolicy
            if ($vdsteampol.ActiveUplinkPort.Length -lt 2)
            {
                $objWrongPathPol = New-Object System.object
                $objWrongPathPol | Add-Member -type NoteProperty -name Host_Name -Value $VMHost.Name
                $objWrongPathPol | Add-Member -type NoteProperty -name vSwitch_Name -Value $portgroup.VDSwitch.Name
                $objWrongPathPol | Add-Member -type NoteProperty -name Port_Group -Value $vdsteampol.VDPortgroup
                $objWrongPathPol | Add-Member -type NoteProperty -name Num_Uplinks -Value $vdsteampol.ActiveUplinkPort.Length
                $objWrongPathPol | Add-Member -type NoteProperty -name LB_Policy -Value $vdsteampol.LoadBalancingPolicy
                $arrteampol += $objWrongPathPol
            }
        }
    }

    #Next get std vSwitch info
    $vSwitch = Get-VirtualSwitch -VMHost $VMHost -Standard
    if ($vSwitch) 
    {
        $objvSwitchPGs = Get-VirtualPortGroup -VirtualSwitch $vSwitch

        foreach ($portgroup in $objvSwitchPGs)
        {
            $vswitchteampol = Get-NicTeamingPolicy -VirtualPortGroup $portgroup
            if ($vswitchteampol.ActiveNic.Length -lt 2)
            {
                $objWrongPathPol = New-Object System.object
                $objWrongPathPol | Add-Member -type NoteProperty -name Host_Name -Value $VMHost.Name
                $objWrongPathPol | Add-Member -type NoteProperty -name vSwitch_Name -Value $portgroup.VirtualSwitch.Name
                $objWrongPathPol | Add-Member -type NoteProperty -name Port_Group -Value $vswitchteampol.VirtualPortgroup
                $objWrongPathPol | Add-Member -type NoteProperty -name Num_Uplinks -Value $vswitchteampol.ActiveNic.Length
                $objWrongPathPol | Add-Member -type NoteProperty -name LB_Policy -Value $vswitchteampol.LoadBalancingPolicy
                $arrteampol += $objWrongPathPol
            }
        }
    }
#endregion get vSwitch info
}



#region generate NIC report	
	foreach ($VMNic in $VMHostNetworkAdapters)
	{
    
		$objDriverInfo = ($esxcli.network.nic.get($VMNic.Name)).DriverInfo
        $objNICProps = $esxcli.network.nic.list() | where-object {$VMNic.name -eq $_.name} | Select-Object Name, Description, Link           
        
        $objOneInt = New-Object System.Object
        $objOneInt | Add-Member -type NoteProperty -name Host_Name -Value $VMHost.Name
        $objOneInt | Add-Member -type NoteProperty -name Int_Name -Value $VMNic.Name
        $objOneInt | Add-Member -type NoteProperty -name Int_Model -Value $objNICProps.Description
        $objOneInt | Add-Member -type NoteProperty -name Int_Driver_Name -Value $objDriverInfo.Driver
        $objOneInt | Add-Member -type NoteProperty -name Int_Driver_Version -Value $objDriverInfo.Version
		$objOneInt | Add-Member -type NoteProperty -name FirmwareVersion -Value $objDriverInfo.FirmwareVersion
        $objOneInt | Add-Member -type NoteProperty -name LUN_Count -Value "N/A"
        $objOneInt | Add-Member -type NoteProperty -name Active_Paths -Value "N/A"
        $objOneInt | Add-Member -type NoteProperty -name Standby_Paths -Value "N/A"
        $objOneInt | Add-Member -type NoteProperty -name Dead_Paths -Value "N/A"
        $objOneInt | Add-Member -type NoteProperty -name Total_Paths -Value "N/A"
        $objOneInt | Add-Member -type NoteProperty -name HostBiosVersion -Value $hostbios
        $objOneInt | Add-Member -type NoteProperty -name HostNTPStatus -Value $ntpstatus.Running
		$arrNicDetail += $objOneInt
	}
	
	$results += $arrNicDetail
#endregion generate NIC report	


#region generate HBA report
try{
    $HBAs = $VMHost | Get-VMHostHba | Where-Object {$_.Status -eq 'online'}# | Where-Object {$_.Type -eq 'FibreChannel'}

    foreach ($vmhba in $HBAs) 
    {

        $driver_name = $vmhba.Driver
        $driver_version = $esxcli.system.module.get($driver_name) | select-object -Expandproperty Version
        $objHBAProps = $esxcli.storage.san.fc.list($vmhba.Device)

        $luncount = 0
        $total = 0
        $active = 0
        $standby = 0
        $dead = 0

        ForEach ($VMHostScsiLun in $VMHostScsiLuns) 
        {
            $luncount++
            $LunPaths = $VMHostScsiLun | Get-ScsiLunPath | Where-Object {$_.Name -like $vmhba.Name + "*"}
            $ActiveLunPaths = $LunPaths | Where-Object {$_.State -eq "Active"}
            $StandbyLunPaths = $LunPaths | Where-Object {$_.State -eq "Standby"}
            $DeadLunPaths = $LunPaths | Where-Object {$_.State -eq "Dead"}
            $active += $ActiveLunPaths.Count
            $standby += $StandbyLunPaths.Count
            $dead += $DeadLunPaths.Count
        }

        $total = $active + $standby + $dead
        $objOneInt = New-Object PSObject
        $objOneInt | Add-Member -type NoteProperty -name Host_Name -Value $VMHost.Name
        $objOneInt | Add-Member -type NoteProperty -name Int_Name -Value $VMHba.Name
        $objOneInt | Add-Member -type NoteProperty -name Int_Model -Value $VMHba.Model
        $objOneInt | Add-Member -type NoteProperty -name Int_Driver_Name -Value $vmhba.Driver
        $objOneInt | Add-Member -type NoteProperty -name Int_Driver_Version -Value $driver_version
        $objOneInt | Add-Member -type NoteProperty -name FirmwareVersion -Value $objHBAProps.FirmwareVersion
        $objOneInt | Add-Member -type NoteProperty -name LUN_Count -Value $luncount
        $objOneInt | Add-Member -type NoteProperty -name Active_Paths -Value $active
        $objOneInt | Add-Member -type NoteProperty -name Standby_Paths -Value $standby
        $objOneInt | Add-Member -type NoteProperty -name Dead_Paths -Value $dead
        $objOneInt | Add-Member -type NoteProperty -name Total_Paths -Value $total
        $objOneInt | Add-Member -type NoteProperty -name HostBiosVersion -Value $hostbios
        $objOneInt | Add-Member -type NoteProperty -name HostNTPStatus -Value $ntpstatus.Running
        $arrHBADetail += $objOneInt

    }

    $results += $arrHBADetail
}  

catch
{
        $objOneInt = New-Object PSObject
        $objOneInt | Add-Member -type NoteProperty -name Host_Name -Value $VMHost.Name
        $objOneInt | Add-Member -type NoteProperty -name Int_Name -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Int_Model -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Int_Driver_Name -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Int_Driver_Version -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name FirmwareVersion -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name LUN_Count -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Active_Paths -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Standby_Paths -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Dead_Paths -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name Total_Paths -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name HostBiosVersion -Value "Access Denied"
        $objOneInt | Add-Member -type NoteProperty -name HostNTPStatus -Value "Access Denied"
        $arrHBADetail += $objOneInt
}
#endregion generate HBA report

#endregion Loop thru hosts
$results | Export-Csv "C:\path\to\file\report.csv"
$arrteampol | Export-Csv "C:\path\to\file\teaming.csv"
