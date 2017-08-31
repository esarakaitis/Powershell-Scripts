param(
	[string]$startdate=$(throw "Start date is required"),
	[string]$vmhost="" #Optional to get stats from only one host.  Default all.
)

$vmhostcmd = "Get-VMHost"
if ($vmhost -ne ""){$vmhostcmd += " -Name $vmhost"}

#Get-VIServer vcprod02

# Get the performance counters that are used for capacity planning for the
# specified host.

#IntervalMins must be set to be larger if the sampling interval goes more than a month back.
$intervalMins = 144

$start = [datetime]::Parse($startdate)
$end = $start.AddDays(7)
$allstats = @()

Write-Host "Getting statistics for $start to $end."

$hosts = Invoke-Expression $vmhostcmd

$hosts | ForEach-Object {
$stats =  $_ | get-stat -IntervalMins $intervalmins -Stat cpu.usage.average,cpu.usagemhz.average,mem.usage.average,disk.usage.average,net.usage.average -MaxSamples 1000 -Start $start.ToUniversalTime() -Finish $end.ToUniversalTime()
$vmhost = $_.Name
Write-Host . -NoNewline

$statholder = New-Object System.Object
$statholder | Add-Member -type NoteProperty -Name hostname -Value $vmhost
$statholder | Add-Member -type NoteProperty -Name Start -Value $start
$statholder | Add-Member -type NoteProperty -Name Finish -Value $end

$statholder | Add-Member -type NoteProperty -Name cpuavg -Value `
    ($stats | Where-Object {$_.MetricId -eq "cpu.usage.average"} | `
    Measure-Object -Property Value -Average).Average

$statholder | Add-Member -type NoteProperty -Name cpumhzaverage -Value `
    ($stats | Where-Object {$_.MetricId -eq "cpu.usagemhz.average"} | `
    Measure-Object -Property Value -Average).Average

$statholder | Add-Member -type NoteProperty -Name memavg -Value `
    ($stats | Where-Object {$_.MetricId -eq "mem.usage.average"} | `
    Measure-Object -Property Value -Average).Average

$statholder | Add-Member -type NoteProperty -Name diskavg -Value `
    ($stats | Where-Object {$_.MetricId -eq "disk.usage.average"} | `
    Measure-Object -Property Value -Average).Average
	
$statholder | Add-Member -type NoteProperty -Name netavg -Value `
    ($stats | Where-Object {$_.MetricId -eq "net.usage.average"} | `
    Measure-Object -Property Value -Average).Average

$allstats += $statholder
}
Write-Host "Done."

$allstats | Export-Csv ("{0}_vmhost_stats.csv" -f $start.ToString("yyyyMMdd")) -noTypeInformation 