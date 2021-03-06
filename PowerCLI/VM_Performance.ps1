#VM Information
Write-Host "Gathering Virtual Machine Information."
function VM-statavg ($vmImpl, $StatStart, $StatFinish, $statId) {
	$stats = $vmImpl | get-stat -Stat $statId -intervalmin 120 -Maxsamples 360 `
							    -Start $StatStart -Finish $StatFinish
	$statAvg = "{0,9:#.00}" -f ($stats | Measure-Object value -average).average
	$statAvg
}
# Report for previous day
$DaysBack = 1 	# Number of days to go back
$DaysPeriod = 1 # Number of days in the interval
$DayStart = (Get-Date).Date.adddays(- $DaysBack)
$DayFinish = (Get-Date).Date.adddays(- $DaysBack + $DaysPeriod).addminutes(-1)
# Report for previous week
$DaysBack = 7 # Number of days to go back
$DaysPeriod = 7 # Number of days in the interval
$WeekStart = (Get-Date).Date.adddays(- $DaysBack)
$WeekFinish = (Get-Date).Date.adddays(- $DaysBack + $DaysPeriod).addminutes(-1)
$report = @()
get-cluster "ENTINT01DU Cluster" | get-vm | Sort Name | % {
  $vm = Get-View $_.ID
    $vms = "" | Select-Object VMName, WeekAvgCpuUsage, VMState, TotalCPU, TotalMemory, WeekAvgMemUsage
    $vms.VMName = $vm.Name
    $vms.WeekAvgCpuUsage = VM-statavg $_ $WeekStart $WeekFinish "cpu.usage.average"
    $vms.VMState = $vm.summary.runtime.powerState
    $vms.TotalCPU = $vm.summary.config.numcpu
    $vms.TotalMemory = $vm.summary.config.memorysizemb
    $vms.WeekAvgMemUsage = VM-statavg $_ $WeekStart $WeekFinish "mem.usage.average"
    $Report += $vms
}
$Report | export-csv c:\guestinfo.csv