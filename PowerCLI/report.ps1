param( [string] $VIServer,[string] $OutputType )

if ($VIServer -eq ""){
	Write-Host
	Write-Host "Please specify a VI Server name eg...."
	Write-Host "      powershell.exe ExcelVIReport.ps1 MYVISERVER <output type>"
	Write-Host
	Write-Host
	exit
}

if ($OutputType -eq ""){
	Write-Host
	Write-Host "Pleast specify an output type."
	Write-Host " excel => Will output an Excel Workbook"
	Write-Host 
	Write-Host
	exit
}

function PreReq
{
	if ((Test-Path  REGISTRY::HKEY_CLASSES_ROOT\Excel.Application) -eq $False){
		Write-Host "This script directly outputs to Microsoft Excel, please install Microsoft Excel"
		exit
	}
	else
	{
		Write-Host "Microsoft Excel Detected"
	}
	if ((Test-Path  REGISTRY::HKEY_CLASSES_ROOT\OWC11.ChartSpace.11) -eq $False){
		Write-Host "This script requires Office Web Components to run correctly, please install these from the following website: http://www.microsoft.com/downloads/details.aspx?FamilyId=7287252C-402E-4F72-97A5-E0FD290D4B76&displaylang=en"
		exit
	}
	Else
	{
		Write-Host "Office Web Components Detected"
	}
	$excelrunning = (Get-Process 'Excel' -ea SilentlyContinue)
	if ( $excelrunning -eq "") {
		Write-Host "Please close all instances of Microsoft Excel before running this report."
		exit
	}
	else
	{
	}
}
## Seven Day (Mon-Sun) 24 Hour CPU/Mem Average Function
function GetHostCpuMemSevenDay24Hour ($esxhost,$output,$iSheet1,$clustername)
{
[System.DateTime]$datestat = Get-Date -Format d
$timezoneoffset = Get-Date -f zz
$dayofweek = [int]$datestat.DayOfWeek
if ($dayofweek -eq 0)
	{ $offset = 0 }
if ($dayofweek -eq 1)
	{ $offset = -1 }
if ($dayofweek -eq 2)
	{ $offset = -2 }
if ($dayofweek -eq 3)
	{ $offset = -3 }
if ($dayofweek -eq 4)
	{ $offset = -4 }
if ($dayofweek -eq 5)
	{ $offset = -5 }
if ($dayofweek -eq 6)
	{ $offset = -6 }
$lastSunday = $datestat.AddDays(-0 + $offset)
$lastMonday = $datestat.AddDays(-6 + $offset)
$lastMondayNoTime = $lastMonday -replace " 12:00:00 AM",""
$lastSundayNoTime = $lastSunday -replace " 12:00:00 AM",""
$endTimeUtc = $lastSunday.AddHours(-($timezoneoffset))
$startTimeUtc = $lastMonday.AddHours(-($timezoneoffset))
$endTime = $endTimeUtc.AddSeconds(86399)
$startTime = $startTimeUtc


	$cpu7 = @(Get-Stat -Entity $esxhost -Stat cpu.usage.average -MaxSamples 1344 -IntervalMins 120 | Where {$_.Timestamp -gt "$startTime" -and $_.Timestamp -lt "$endTime"} | Select Value)
	$cpu7Avg = ($cpu7 | Measure-Object -Property Value -Average).Average
	$cpu7AvgRound = [Math]::Round($cpu7Avg, 2)
	
	$mem7 = @(Get-Stat -Entity $esxhost -Stat mem.usage.average -MaxSamples 1344 -IntervalMins 120 | Where {$_.Timestamp -gt "$startTime" -and $_.Timestamp -lt "$endTime"} | Select Value)
	$mem7Avg = ($mem7 | Measure-Object -Property Value -Average).Average
	$mem7AvgRound = [Math]::Round($mem7Avg, 2)
	
 if ($output -eq "excel" -or $output -eq "both")
 {
 ##Write results to the Excel Spreadsheet
 $excelSheet1 = $excelBook.WorkSheets.item(1)
 $excelSheet1.cells.item($iSheet1,1)="$lastMondayNoTime - $lastSundayNoTime"
 $excelSheet1.cells.item($iSheet1,2)="$clustername"
 $excelSheet1.cells.item($iSheet1,3)="$esxhost"
 $excelSheet1.cells.item($iSheet1,4)=$cpu7AvgRound
 $excelSheet1.cells.item($iSheet1,5)=$mem7AvgRound
 }
 ##Color code the cell yellow or red if above warning thresholds
 if ($cpu7AvgRound -gt 75)
 {
 	$excelSheet1.cells.item($iSheet1,4).Interior.Color = 255
 }
  if ($mem7AvgRound -gt 75)
 {
 	$excelSheet1.cells.item($iSheet1,5).Interior.Color = 255
 }
 if ($cpu7AvgRound -gt 40 -and $cpu7AvgRound -lt 75)
 {
 	$excelSheet1.cells.item($iSheet1,4).Interior.Color = 255,255,0
 }
  if ($mem7AvgRound -gt 40 -and $mem7AvgRound -lt 75)
 {
 	$excelSheet1.cells.item($iSheet1,5).Interior.Color = 255,255,0
 }
}
## Five Day (Mon-Fri) 24 Hour CPU/Mem Average Function
function GetHostCpuMemFiveDay24Hour ($esxhost,$output,$iSheet2,$clustername)
{
[System.DateTime]$datestat = Get-Date -Format d
$timezoneoffset = Get-Date -f zz
$dayofweek = [int]$datestat.DayOfWeek
if ($dayofweek -eq 0)
	{ $offset = 0 }
if ($dayofweek -eq 1)
	{ $offset = -1 }
if ($dayofweek -eq 2)
	{ $offset = -2 }
if ($dayofweek -eq 3)
	{ $offset = -3 }
if ($dayofweek -eq 4)
	{ $offset = -4 }
if ($dayofweek -eq 5)
	{ $offset = -5 }
if ($dayofweek -eq 6)
	{ $offset = -6 }
$lastFriday = $datestat.AddDays(-2 + $offset)
$lastMonday = $datestat.AddDays(-6 + $offset)
$endTimeUtc = $lastFriday.AddHours(-($timezoneoffset))
$startTimeUtc = $lastMonday.AddHours(-($timezoneoffset))
$endTime = $endTimeUtc.AddSeconds(86399)
$startTime = $startTimeUtc
$lastMondayNoTime = $lastMonday -replace " 12:00:00 AM",""
$lastFridayNoTime = $lastFriday -replace " 12:00:00 AM",""

	$cpu5 = @(Get-Stat -Entity $esxhost -Stat cpu.usage.average -MaxSamples 1344 -IntervalMins 120 | Where {$_.Timestamp -gt "$startTime" -and $_.Timestamp -lt "$endTime"} | Select Value)
	$cpu5Avg = ($cpu5 | Measure-Object -Property Value -Average).Average
	$cpu5AvgRound = [Math]::Round($cpu5Avg, 2)
	
	$mem5 = @(Get-Stat -Entity $esxhost -Stat mem.usage.average -MaxSamples 1344 -IntervalMins 120 | Where {$_.Timestamp -gt "$startTime" -and $_.Timestamp -lt "$endTime"} | Select Value)
	$mem5Avg = ($mem5 | Measure-Object -Property Value -Average).Average
	$mem5AvgRound = [Math]::Round($mem5Avg, 2)
		
		
if ($output -eq "excel" -or $output -eq "both")
	{
		##Write results to the Excel Spreadsheet
		$excelSheet2 = $excelBook.WorkSheets.item(2)
		$excelSheet2.cells.item($iSheet2,1)="$lastMondayNoTime - $lastFridayNoTime"
		$excelSheet2.cells.item($iSheet2,2)="$clustername"
		$excelSheet2.cells.item($iSheet2,3)="$esxhost"
		$excelSheet2.cells.item($iSheet2,4)=$cpu5AvgRound
		$excelSheet2.cells.item($iSheet2,5)=$mem5AvgRound
	}
##Color code the cell yellow or red if above warning thresholds
 if ($cpu5AvgRound -gt 75)
 {
 	$excelSheet2.cells.item($iSheet2,4).Interior.Color = 255
 }
  if ($mem5AvgRound -gt 75)
 {
 	$excelSheet2.cells.item($iSheet2,5).Interior.Color = 255
 }
 if ($cpu5AvgRound -gt 40 -and $cpu5AvgRound -lt 75)
 {
 	$excelSheet2.cells.item($iSheet2,4).Interior.Color = 255,255,0
 }
  if ($mem5AvgRound -gt 40 -and $mem5AvgRound -lt 75)
 {
 	$excelSheet2.cells.item($iSheet2,5).Interior.Color = 255,255,0
 }
}
## Five Day (Mon-Fri) Business Hour CPU/Mem Average Function
function GetHostCpuMemFiveDayBusinessHour ($esxhost,$output,$iSheet3,$clustername)
{
[System.DateTime]$datestat = Get-Date -Format d
$timezoneoffset = Get-Date -f zz
$dayofweek = [int]$datestat.DayOfWeek
if ($dayofweek -eq 0)
	{ $offset = 0 }
if ($dayofweek -eq 1)
	{ $offset = -1 }
if ($dayofweek -eq 2)
	{ $offset = -2 }
if ($dayofweek -eq 3)
	{ $offset = -3 }
if ($dayofweek -eq 4)
	{ $offset = -4 }
if ($dayofweek -eq 5)
	{ $offset = -5 }
if ($dayofweek -eq 6)
	{ $offset = -6 }
$lastFriday = $datestat.AddDays(-2 + $offset)
$lastThursday = $datestat.AddDays(-3 + $offset)
$lastWednesday = $datestat.AddDays(-4 + $offset)
$lastTuesday = $datestat.AddDays(-5 + $offset)
$lastMonday = $datestat.AddDays(-6 + $offset)
$TimeFridayUtc = $lastFriday.AddHours(-($timezoneoffset))
$TimeThursdayUtc = $lastThursday.AddHours(-($timezoneoffset))
$TimeWednesdayUtc = $lastWednesday.AddHours(-($timezoneoffset))
$TimeTuesdayUtc = $lastTuesday.AddHours(-($timezoneoffset))
$TimeMondayUtc = $lastMonday.AddHours(-($timezoneoffset))
$endTimeFriday = $TimeFridayUtc.AddHours(18)
$startTimeFriday = $TimeFridayUtc.AddHours(7)
$endTimeThursday = $TimeThursdayUtc.AddHours(18)
$startTimeThursday = $TimeThursdayUtc.AddHours(7)
$endTimeWednesday = $TimeWednesdayUtc.AddHours(18)
$startTimeWednesday = $TimeWednesdayUtc.AddHours(7)
$endTimeTuesday = $TimeTuesdayUtc.AddHours(18)
$startTimeTuesday = $TimeTuesdayUtc.AddHours(7)
$endTimeMonday = $TimeMondayUtc.AddHours(18)
$startTimeMonday = $TimeMondayUtc.AddHours(7)
$lastMondayNoTime = $lastMonday -replace " 12:00:00 AM",""
$lastFridayNoTime = $lastFriday -replace " 12:00:00 AM",""

	$cpu585cmd = Get-Stat -Entity $esxhost -Stat cpu.usage.average -MaxSamples 1344 -IntervalMins 120
	$cpu585Monday = @($cpu585cmd | Where {$_.Timestamp -gt "$startTimeMonday" -and $_.Timestamp -lt "$endTimeMonday"} | Select Timestamp,Value)
	$cpu585Tuesday = @($cpu585cmd | Where {$_.Timestamp -gt "$startTimeTuesday" -and $_.Timestamp -lt "$endTimeTuesday"} | Select Timestamp,Value)
	$cpu585Wednesday = @($cpu585cmd | Where {$_.Timestamp -gt "$startTimeWednesday" -and $_.Timestamp -lt "$endTimeWednesday"} | Select Timestamp,Value)
	$cpu585Thursday = @($cpu585cmd | Where {$_.Timestamp -gt "$startTimeThursday" -and $_.Timestamp -lt "$endTimeThursday"} | Select Timestamp,Value)
	$cpu585Friday = @($cpu585cmd | Where {$_.Timestamp -gt "$startTimeFriday" -and $_.Timestamp -lt "$endTimeFriday"} | Select Timestamp,Value)
	$cpu585MondayAvg = ($cpu585Monday | Measure-Object -Property Value -Average).Average
	$cpu585MondayAvgRound = [Math]::Round($cpu585MondayAvg, 2)
	$cpu585TuesdayAvg = ($cpu585Tuesday | Measure-Object -Property Value -Average).Average
	$cpu585TuesdayAvgRound = [Math]::Round($cpu585TuesdayAvg, 2)
	$cpu585WednesdayAvg = ($cpu585Wednesday | Measure-Object -Property Value -Average).Average
	$cpu585WednesdayAvgRound = [Math]::Round($cpu585WednesdayAvg, 2)
	$cpu585ThursdayAvg = ($cpu585Thursday | Measure-Object -Property Value -Average).Average
	$cpu585ThursdayAvgRound = [Math]::Round($cpu585ThursdayAvg, 2)
	$cpu585FridayAvg = ($cpu585Friday | Measure-Object -Property Value -Average).Average
	$cpu585FridayAvgRound = [Math]::Round($cpu585FridayAvg, 2)
	$cpu585TotalAvg = ($cpu585MondayAvgRound + $cpu585TuesdayAvgRound + $cpu585WednesdayAvgRound + $cpu585ThursdayAvgRound + $cpu585FridayAvgRound) / 5
	$cpu585TotalAvgRound = [Math]::Round($cpu585TotalAvg, 2)
	
	$mem585cmd = Get-Stat -Entity $esxhost -Stat mem.usage.average -MaxSamples 1344 -IntervalMins 120
	$mem585Monday = @($mem585cmd | Where {$_.Timestamp -gt "$startTimeMonday" -and $_.Timestamp -lt "$endTimeMonday"} | Select Timestamp,Value)
	$mem585Tuesday = @($mem585cmd | Where {$_.Timestamp -gt "$startTimeTuesday" -and $_.Timestamp -lt "$endTimeTuesday"} | Select Timestamp,Value)
	$mem585Wednesday = @($mem585cmd | Where {$_.Timestamp -gt "$startTimeWednesday" -and $_.Timestamp -lt "$endTimeWednesday"} | Select Timestamp,Value)
	$mem585Thursday = @($mem585cmd | Where {$_.Timestamp -gt "$startTimeThursday" -and $_.Timestamp -lt "$endTimeThursday"} | Select Timestamp,Value)
	$mem585Friday = @($mem585cmd | Where {$_.Timestamp -gt "$startTimeFriday" -and $_.Timestamp -lt "$endTimeFriday"} | Select Timestamp,Value)
	$mem585MondayAvg = ($mem585Monday | Measure-Object -Property Value -Average).Average
	$mem585MondayAvgRound = [Math]::Round($mem585MondayAvg, 2)
	$mem585TuesdayAvg = ($mem585Tuesday | Measure-Object -Property Value -Average).Average
	$mem585TuesdayAvgRound = [Math]::Round($mem585TuesdayAvg, 2)
	$mem585WednesdayAvg = ($mem585Wednesday | Measure-Object -Property Value -Average).Average
	$mem585WednesdayAvgRound = [Math]::Round($mem585WednesdayAvg, 2)
	$mem585ThursdayAvg = ($mem585Thursday | Measure-Object -Property Value -Average).Average
	$mem585ThursdayAvgRound = [Math]::Round($mem585ThursdayAvg, 2)
	$mem585FridayAvg = ($mem585Friday | Measure-Object -Property Value -Average).Average
	$mem585FridayAvgRound = [Math]::Round($mem585FridayAvg, 2)
	$mem585TotalAvg = ($mem585MondayAvgRound + $mem585TuesdayAvgRound + $mem585WednesdayAvgRound + $mem585ThursdayAvgRound + $mem585FridayAvgRound) / 5
	$mem585TotalAvgRound = [Math]::Round($mem585TotalAvg, 2)
	
if ($output -eq "excel" -or $output -eq "both")
	{
		##Write results to the Excel Spreadsheet
		$excelSheet3 = $excelBook.WorkSheets.item(3)
		$excelSheet3.cells.item($iSheet3,1)="$lastMondayNoTime - $lastFridayNoTime"
		$excelSheet3.cells.item($iSheet3,2)="$clustername"
		$excelSheet3.cells.item($iSheet3,3)="$esxhost"
		$excelSheet3.cells.item($iSheet3,4)=$cpu585TotalAvgRound
		$excelSheet3.cells.item($iSheet3,5)=$mem585TotalAvgRound
	}
 ##Color code the cell yellow or red if above warning/critical thresholds
 if ($cpu585TotalAvgRound -gt 75)
 {
 	$excelSheet3.cells.item($iSheet3,4).Interior.Color = 255
 }
  if ($mem585TotalAvgRound -gt 75)
 {
 	$excelSheet3.cells.item($iSheet3,5).Interior.Color = 255
 }
 if ($cpu585TotalAvgRound -gt 40 -and $cpu585TotalAvgRound -lt 75)
 {
 	$excelSheet3.cells.item($iSheet3,4).Interior.Color = 255,255,0
 }
  if ($mem585TotalAvgRound -gt 40 -and $mem585TotalAvgRound -lt 75)
 {
 	$excelSheet3.cells.item($iSheet3,5).Interior.Color = 255,255,0
 }
}
## Host Hardware Function 
function GetHostHardware ($esxhost,$output,$iSheet4,$clustername)
{
$contents = @()

  
  $esx = Get-VMHost $esxhost | Get-View
    $esxs = "" | Select-Object Model, Memory, CpuModel, CPUMHz, NumCpuPkgs, NumCpuCores, NumCpuThreads, NumNics, NumHBAs
	$esxmemKb = $esx.Summary.Hardware.MemorySize / 1024
	$esxmemMB = $esxmemKb / 1024
	$esxmemGB = $esxmemMB / 1024
    $esxs.Model = $esx.Summary.Hardware.Model
	$esxs.Memory = $esxmemGB
    $esxs.CpuModel = $esx.Summary.Hardware.CpuModel
    $esxs.CPUMHz = $esx.Summary.Hardware.CpuMhz
    $esxs.NumCpuPkgs = $esx.Summary.Hardware.NumCpuPkgs
    $esxs.NumCpuCores = $esx.Summary.Hardware.NumCpuCores
	$esxs.NumCpuThreads = $esx.Summary.Hardware.NumCpuThreads
	$esxs.NumNics = $esx.Summary.Hardware.NumNics
	$esxs.NumHBAs = $esx.Summary.Hardware.NumHBAs
    
	if ($output -eq "excel" -or $output -eq "both")
	{
	$excelSheet4 = $excelBook.WorkSheets.item(4)
	$excelSheet4.cells.item($iSheet4,1) = "$clustername"
	$excelSheet4.cells.item($iSheet4,2) = "$esxhost"
	$excelSheet4.cells.item($iSheet4,3) = $esxs.Model
	$excelSheet4.cells.item($iSheet4,4) = $esxs.CpuModel
	$excelSheet4.cells.item($iSheet4,5) = $esxs.Memory
	$excelSheet4.cells.item($iSheet4,6) = $esxs.CPUMHz
	$excelSheet4.cells.item($iSheet4,7) = $esxs.NumCpuPkgs
	$excelSheet4.cells.item($iSheet4,8) = $esxs.NumCpuCores
	$excelSheet4.cells.item($iSheet4,9) = $esxs.NumCpuThreads
	$excelSheet4.cells.item($iSheet4,10) = $esxs.NumNics
	$excelSheet4.cells.item($iSheet4,11) = $esxs.NumHBAs
	}
}
## Datastore functions
function DatastoreInfo ($datastore,$output,$iSheet6,$clustername)
{
$ds = Get-Datastore -Name $datastore | Sort-Object FreeSpaceMB
$datastores = "" | Select-Object Name, CapacityMB, FreeSpaceMB
$datastores.Name = $ds.Name
$datastores.CapacityMB = $ds.CapacityMB
$datastores.FreeSpaceMB = $ds.FreeSpaceMB
$datastoreCapacityGB = $ds.CapacityMB / 1024
$datastoreCapacityGBRound = [Math]::Round($datastoreCapacityGB, 2)
$datastoreFreeSpaceGB = $ds.FreeSpaceMB / 1024
$datastoreFreeSpaceGBRound = [Math]::Round($datastoreFreeSpaceGB, 2)
$datastorePercentFree = ($ds.FreeSpaceMB / $ds.CapacityMB) * 100
$datastorePercentFreeRound = [Math]::Round($datastorePercentFree, 2)

if ($output -eq "excel" -or $output -eq "both")
	{
	$excelSheet6 = $excelBook.WorkSheets.item(6)
	$excelSheet6.cells.item($iSheet6,1) = "$clustername"
	$excelSheet6.cells.item($iSheet6,2) = $datastores.Name
	$excelSheet6.cells.item($iSheet6,3) = $datastoreCapacityGBRound
	$excelSheet6.cells.item($iSheet6,4) = $datastoreFreeSpaceGBRound
	$excelSheet6.cells.item($iSheet6,5) = $datastores.CapacityMB
	$excelSheet6.cells.item($iSheet6,6) = $datastores.FreeSpaceMB
	$excelSheet6.cells.item($iSheet6,7) = "$datastorePercentFreeRound %"
	}
	
}

## Let's get the Extent info for each Datastore and the preferred/active paths
function DataStoreExtentInfo ($lun,$ds2Host,$output,$iSheet6)
{
$hostView = Get-View $ds2Host
$storageSystem = Get-View $hostView.ConfigManager.StorageSystem
foreach ($lun2 in $storageSystem.StorageDeviceInfo.MultipathInfo.lun)
	{
		if ($lun -eq $lun2.Id)
			{
				foreach ($path in $lun2.Path)
				{
					if ($path.PathState -eq "active")
						{
							$lunActivePath = $path.Name
						}
				}
					$lunName = $lun2.Id
					$lunPolicy = $lun2.Policy.Policy
					$lunPrefpath = $lun2.Policy.Prefer
					if ($lunPrefpath -eq $lunActivePath -or $lunPolicy -eq "mru")
						{
							$pathMismatch = "No"
						}
					elseif ($lunPrefpath -ne $lunpath -and $lunPolicy -ne "mru")
						{
							$pathMismatch = "Yes"
						}
					if ($output -eq "excel" -or $output -eq "both")
					{
					$excelSheet6 = $excelBook.WorkSheets.item(6)
					$excelSheet6.cells.item($iSheet6,8) = $lunName
					$excelSheet6.cells.item($iSheet6,9) = $lunPolicy
					$excelSheet6.cells.item($iSheet6,10) = $lunPrefpath
					$excelSheet6.cells.item($iSheet6,11) = $lunActivePath
					$excelSheet6.cells.item($iSheet6,12) = $pathMismatch
					}
					if ($pathMismatch -eq "Yes")
					{
						$excelSheet6.cells.item($iSheet6,12).Interior.Color = 255
					}
}
}
}

## VM Guest Information Function
function GetClusterVmInfo ($clustername,$vmname,$output,$iSheet5)
{
  $vm = Get-View $vmname.ID
  $vmos = Get-VMGuest $vm.Name
  $vmdisk = @(Get-HardDisk $vm.Name | Select CapacityKb)
  $vmdiskclean = $vmdisk -replace "@{CapacityKB=","" -replace "}","" -replace "\s+(?!$)","`,"
  $vmdisktotalKb = 0
  foreach ($driveCapacity in $vmdiskclean)
  {$vmdisktotalKb += $driveCapacity}
  $vmdisktotalMB = $vmdisktotalKb / 1024
  $vmdisktotalGB = $vmdisktotalMB / 1024
    $vms = "" | Select-Object Name, OS, vCPUs, MBMemory, VMToolsStatus, VMToolsVersion, DiskSizeGB, Description
    $vms.Name = $vm.Name
	$vms.OS = $vmos.OSFullName 
	$vms.vCPUs = $vm.summary.config.numcpu
    $vms.MBMemory = $vm.summary.config.memorysizemb
    $vms.VMToolsStatus = $vm.guest.toolsstatus
    $vms.VMToolsVersion = $vm.config.tools.toolsversion
	$vms.DiskSizeGB = $vmdisktotalGB
	$vms.Description = $vm.Config.Annotation
	
	if ($output -eq "excel" -or $output -eq "both")
	{
		$excelSheet5 = $excelBook.WorkSheets.item(5)
		$excelSheet5.cells.item($iSheet5,1)="$clustername"
		$excelSheet5.cells.item($iSheet5,2)=$vms.Name
		$excelSheet5.cells.item($iSheet5,3)=$vms.OS
		$excelSheet5.cells.item($iSheet5,4)=$vms.vCPUs
		$excelSheet5.cells.item($iSheet5,5)=$vms.MBMemory
		$excelSheet5.cells.item($iSheet5,6)=$vms.VMToolsStatus
		$excelSheet5.cells.item($iSheet5,7)=$vms.VMToolsVersion
		$excelSheet5.cells.item($iSheet5,8)=$vms.DiskSizeGB
		$excelSheet5.cells.item($iSheet5,9)=$vms.Description
	}
}
function GetSnapshotInfo ($vmnamesnap,$snapshot,$output,$iSheet7)
{
$snap = Get-Snapshot $vmnamesnap
    $snaps = "" | Select-Object Created, Description
	$snaps.Created = $snap.Created
	$snaps.Description = $snap.Description
	
	if ($output -eq "excel" -or $output -eq "both")
	{
		$excelSheet7 = $excelBook.WorkSheets.item(7)
		$excelSheet7.cells.item($iSheet7,1)="$vmnamesnap"
		$excelSheet7.cells.item($iSheet7,2)=$snaps.Created
		$excelSheet7.cells.item($iSheet7,3)=$snaps.Description
	}
}


## Get the date and run the prerequisites function
$date = Get-date
Prereq

# Connect to the VI Server
Write-Host "Connecting to VI Server"
Connect-VIServer $VIServer

#Setting common used commands to speed things up
Write-Host "Setting Variables...Please wait"
$VMs = Get-VM
$VMHs = Get-VMHost
$Ds = Get-Datastore
$rp = Get-resourcepool
$clu = Get-Cluster



## Determine if the user wants to output Excel and start creating the workbook
if ($OutputType -eq "excel")
{
Write-Host "Creating New Excel Workbook"
$msExcel = New-Object -ComObject Excel.Application
## Create the Workbook
$msExcel.SheetsInNewWorkbook = 7
$excelBook = $msExcel.Workbooks.Add()
## Make Excel visible (optional)
$msExcel.Visible = $false
## Create the Wroksheets
$excelBook.Worksheets.Item(1)
$excelBook.Worksheets.Item(2)
$excelBook.Worksheets.Item(3)
$excelBook.Worksheets.Item(4)
$excelBook.Worksheets.Item(5)
$excelBook.Worksheets.Item(6)
$excelBook.Worksheets.Item(7)
## Activate the workbook
$excelBook.Activate()

### Let's start with the seven day 24 hour averages of CPU and memory
 $excelSheet1 = $excelBook.WorkSheets.item(1)
 $excelSheet1.cells.item(1,1)="Date Range"
 $excelSheet1.cells.item(1,2)="Cluster Name"
 $excelSheet1.cells.item(1,3)="Host Name"
 $excelSheet1.cells.item(1,4)="Average CPU %"
 $excelSheet1.cells.item(1,5)="Average Mem %"
 $excelSheet1.Name = "7 Day 24 Hour Averages"
 ## Bold the master row 
 $sheet1Range = $excelSheet1.UsedRange
 $sheet1Range.Font.Bold = $true
 $sheet1Range.EntireColumn.AutoFit()
 $iSheet1=2

foreach ($clustername in $clu | Sort-Object Name)
		{
		$esxhosts = @(Get-Cluster $clustername |Sort-Object Name | Get-VMHost)
		foreach ($esxhost in $esxhosts)
		{
		$output = "excel"
		GetHostCpuMemSevenDay24Hour $esxhost $output $iSheet1 $clustername
	 	$iSheet1=$iSheet1+1
		}
		## Autofit all of the columns
		$sheet1Range.EntireColumn.AutoFit()
	}

## Now let's get the five day 24-hour averages of CPU and memory
 $excelSheet2 = $excelBook.WorkSheets.item(2)
 $excelSheet2.cells.item(1,1)="Date Range"
 $excelSheet2.cells.item(1,2)="Cluster Name"
 $excelSheet2.cells.item(1,3)="Host Name"
 $excelSheet2.cells.item(1,4)="Average CPU %"
 $excelSheet2.cells.item(1,5)="Average Mem %"
 $excelSheet2.Name = "5 Day 24 Hour Averages"
 ## Bold the master row 
 $sheet2Range = $excelSheet2.UsedRange
 $sheet2Range.Font.Bold = $true
 $sheet2Range.EntireColumn.AutoFit()
 $iSheet2=2

foreach ($clustername in $clu | Sort-Object Name)
		{
		$esxhosts = @(Get-Cluster $clustername |Sort-Object Name | Get-VMHost)
		foreach ($esxhost in $esxhosts)
		{
		$output = "excel"
		GetHostCpuMemFiveDay24Hour $esxhost $output $iSheet2 $clustername
	 	$iSheet2=$iSheet2+1
		}
		## Autofit all of the columns
		$sheet2Range.EntireColumn.AutoFit()
		}
	
## Now let's get the five day business hour averages of CPU and memory
 $excelSheet3 = $excelBook.WorkSheets.item(3)
 $excelSheet3.cells.item(1,1)="Date Range"
 $excelSheet3.cells.item(1,2)="Cluster Name"
 $excelSheet3.cells.item(1,3)="Host Name"
 $excelSheet3.cells.item(1,4)="Average CPU %"
 $excelSheet3.cells.item(1,5)="Average Mem %"
 $excelSheet3.Name = "5 Day Business Hour Averages"
 ## Bold the master row 
 $sheet3Range = $excelSheet3.UsedRange
 $sheet3Range.Font.Bold = $true
 $sheet3Range.EntireColumn.AutoFit()
 $iSheet3=2

foreach ($clustername in $clu | Sort-Object Name)
		{
		$esxhosts = @(Get-Cluster $clustername |Sort-Object Name | Get-VMHost)
		foreach ($esxhost in $esxhosts)
		{
		$output = "excel"
		GetHostCpuMemFiveDayBusinessHour $esxhost $output $iSheet3 $clustername
	 	$iSheet3=$iSheet3+1
		}
		## Autofit all of the columns
		$sheet3Range.EntireColumn.AutoFit()
		}
	
## Now let's enter our Host Hardware information
$excelSheet4 = $excelBook.WorkSheets.item(4)
$excelSheet4.cells.item(1,1)="Cluster Name"
$excelSheet4.cells.item(1,2)="Host Name"
$excelSheet4.cells.item(1,3)="Model"
$excelSheet4.cells.item(1,4)="CPU Model"
$excelSheet4.cells.item(1,5)="Memory (GB)"
$excelSheet4.cells.item(1,6)="CPU MHz"
$excelSheet4.cells.item(1,7)="# CPU"
$excelSheet4.cells.item(1,8)="# Cores"
$excelSheet4.cells.item(1,9)="# Threads"
$excelSheet4.cells.item(1,10)="# NICs"
$excelSheet4.cells.item(1,11)="# HBAs"
$excelSheet4.Name = "Host Hardware"
## Bold the master row 
$sheet4Range = $excelSheet4.UsedRange
$sheet4Range.Font.Bold = $true
$sheet4Range.EntireColumn.AutoFit()
$iSheet4=2

foreach ($clustername in $clu |Sort-Object Name)
		{
		$esxhosts = @(Get-Cluster $clustername |Sort-Object Name | Get-VMHost)
		foreach ($esxhost in $esxhosts)
		{
		$output = "excel"
		GetHostHardware $esxhost $output $iSheet4 $clustername
	 	$iSheet4=$iSheet4+1
		}
		## Autofit all of the columns
		$sheet4Range.EntireColumn.AutoFit()
		}

## Let's enter our VM Info
$excelSheet5 = $excelBook.WorkSheets.item(5)
$excelSheet5.cells.item(1,1)="Cluster Name"
$excelSheet5.cells.item(1,2)="Name"
$excelSheet5.cells.item(1,3)="OS"
$excelSheet5.cells.item(1,4)="# vCPUs"
$excelSheet5.cells.item(1,5)="Memory (MB)"
$excelSheet5.cells.item(1,6)="VMTools Status"
$excelSheet5.cells.item(1,7)="VMTools Version"
$excelSheet5.cells.item(1,8)="Disk Size (GB)"
$excelSheet5.cells.item(1,9)="Description"
$excelSheet5.Name = "VM Info"
## Bold the master row 
$sheet5Range = $excelSheet5.UsedRange
$sheet5Range.Font.Bold = $true
$sheet5Range.EntireColumn.AutoFit()
$iSheet5=2

foreach ($clustername in $clu | Sort-Object Name)
		{
		$vmlist = @(Get-Cluster $clustername | Get-VM)
		foreach ($vmname in $vmlist)
		{
		$output = "excel"
		GetClusterVmInfo $clustername $vmname $output $iSheet5 
		$iSheet5=$iSheet5+1
		}
		## Autofit all of the columns
		$sheet5Range.EntireColumn.AutoFit()
		}

## Now let's enter our Datastore information
$excelSheet6 = $excelBook.WorkSheets.item(6)
$excelSheet6.cells.item(1,1)="Cluster Name"
$excelSheet6.cells.item(1,2)="Datastore Name"
$excelSheet6.cells.item(1,3)="Capacity GB"
$excelSheet6.cells.item(1,4)="Free Space GB"
$excelSheet6.cells.item(1,5)="Capacity MB"
$excelSheet6.cells.item(1,6)="Free Space MB"
$excelSheet6.cells.item(1,7)="Percent Free Space"
$excelSheet6.cells.item(1,8)="Extent Name"
$excelSheet6.cells.item(1,9)="Multipath Policy"
$excelSheet6.cells.item(1,10)="Preferred Path"
$excelSheet6.cells.item(1,11)="Active Path"
$excelSheet6.cells.item(1,12)="Path Mismatch"
$excelSheet6.Name = "Datastore Information"
## Bold the master row 
$sheet6Range = $excelSheet6.UsedRange
$sheet6Range.Font.Bold = $true
$sheet6Range.EntireColumn.AutoFit()
$iSheet6=2

foreach ($clustername in $clu |Sort-Object Name)
		{
		$datastores = @(Get-Cluster $clustername | Get-VMHost | Get-Datastore)
		foreach ($datastore in $datastores)
		{
		$output = "excel"
		DatastoreInfo $datastore $output $iSheet6 $clustername
		
	 	$ds2 = Get-Datastore $datastore | Get-View 
		$ds2HostId = ($ds2.Host[0].Key.Value)
		$ds2Host = "HostSystem-$ds2HostId"
		$hostView = Get-View $ds2Host
		$storageSystem = Get-View $hostView.ConfigManager.StorageSystem
		foreach ($mount in $storageSystem.FileSystemVolumeInfo.MountInfo)
		{
			if ($mount.Volume.Name -eq $datastore)

			{
			foreach ($lun in $mount.Volume.Extent)
			{
			DataStoreExtentInfo $lun.DiskName $ds2Host $output $iSheet6
			$iSheet6=$iSheet6+1
			}
			}

		
		}
		## Autofit all of the columns
		$sheet6Range.EntireColumn.AutoFit()
		}
}
		
## Now we'll gather the snapshot information
$excelSheet7 = $excelBook.WorkSheets.item(7)
$excelSheet7.cells.item(1,1)="VM Name"
$excelSheet7.cells.item(1,2)="Date Created"
$excelSheet7.cells.item(1,3)="Description"
$excelSheet7.Name = "Snapshot Information"
## Bold the master row 
$sheet7Range = $excelSheet7.UsedRange
$sheet7Range.Font.Bold = $true
$sheet7Range.EntireColumn.AutoFit()
$iSheet7=2

foreach ($vm in Get-VM | Get-Snapshot | Select VM )
		{
		$snapshots = Get-Snapshot $vm.VM 
	foreach ($snapshot in $snapshot)
		{
			$output = "excel"
			GetSnapshotInfo $vm.VM $snapshot $output $iSheet7
			$iSheet7=$iSheet7+1
		}
		## Autofit all of the columns
		$sheet7Range.EntireColumn.AutoFit()
		}
		
## Show the finished Workbook
$msExcel.Visible = $true

## Save the workbook to disk and close
$excelfilename = 'C:\VMReport.xls'
$excelBook.SaveAs($excelfilename)
#$msExcel.Quit()
}
