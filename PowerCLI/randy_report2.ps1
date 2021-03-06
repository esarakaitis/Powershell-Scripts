$initalTime = Get-Date
$filepath = "C:\tmp"
$filename = "forecast"
$date = Get-Date ($initalTime) -uformat %Y%m%d
$time = Get-Date ($initalTime) -uformat %H%M

Write-Host "$(Get-Date ($initalTime) -uformat %H:%M:%S) - Starting"

$VCList = @("us-hil-vmvc-01.ads-pipe.com")

Write-Host "$(Get-Date -uformat %H:%M:%S) - $(($VCList | Measure-Object).Count) VC(s) acquired"

$TotalNumHosts = 0
$TotalCpu = 0
$TotalMemory = 0
$TotalMemoryAllocated = 0
$TotalGuests = 0

$i = 0
$report = @()
if ((($VCList | Measure-Object).Count) -gt 0) {
    ForEach ($VC in $VCList) {
        $i++
        Write-Host "$(Get-Date -uformat %H:%M:%S) - $($i) of $(($VCList | Measure-Object).Count) - $($VC)"
        $VMClusterList = Get-View -Server $VC -ViewType ClusterComputeResource | Sort-Object Name
        Write-Host "$(Get-Date -uformat %H:%M:%S) - $(($VMClusterList | Measure-Object).Count) Cluster(s) acquired"
        
        $j = 0
        if ((($VMClusterList | Measure-Object).Count) -gt 0) {
            ForEach ($VMCluster in $VMClusterList) {
                $j++
                Write-Host "$(Get-Date -uformat %H:%M:%S) - $($j) of $(($VMClusterList | Measure-Object).Count) - $($VMCluster.Name)"
                $VMClusterHostNames = Get-View -Server $VC -ViewType ClusterComputeResource -Filter @{"Name"=$VMCluster.Name} | Select-Object -ExpandProperty Host | Select-Object -ExpandProperty Value
                $VMHostNameLoopCount = 0
                $VMHostNameList = ""
                foreach ($VMHostName in $VMClusterHostNames) {
                    $VMHostNameLoopCount++
                    if ($VMHostNameLoopCount -gt 1) {
                        $VMHostNameList += "|^"+$VMHostName+"$"
                    } else {
                        $VMHostNameList += "^"+$VMHostName+"$"
                    }
                }
                $VMClusterGuestList = Get-View -Server $VC -ViewType VirtualMachine -Filter @{"Runtime.Host"=$VMHostNameList; "Runtime.PowerState"="poweredOn"; "Config.Template"="False"} | Sort-Object Name
                $VMClusterTotalCpu = ($VMCluster.Summary.TotalCpu / 1000)
                $VMClusterTotalMemory = ($VMCluster.Summary.TotalMemory / (1024 * 1024 * 1024))
                $VMClusterAllocatedGuestMemoryMB = (($VMClusterGuestList | Select-Object -ExpandProperty Config | Select-Object -ExpandProperty Hardware | Measure-Object -Property MemoryMB -Sum).Sum / 1024)
                $TotalNumHosts += $VMCluster.Summary.NumHosts
                $TotalCpu += $VMClusterTotalCpu
                $TotalMemory += $VMClusterTotalMemory
                $TotalMemoryAllocated += $VMClusterAllocatedGuestMemoryMB
                $TotalGuests += (($VMClusterGuestList | Measure-Object).Count)
                if ((($VMClusterGuestList | Measure-Object).Count) -gt 0) {
                    Write-Host "$(Get-Date -uformat %H:%M:%S) - $($VMCluster.Name) - $($VMCluster.Summary.NumHosts) Host(s) - $("{0:N0}" -f ($VMClusterTotalCpu)) GHz & $("{0:N2}" -f ($VMClusterTotalMemory)) GB - $(($VMClusterGuestList | Measure-Object).Count) Guest(s) - $("{0:N2}" -f ($VMClusterAllocatedGuestMemoryMB)) GB w/ avg $("{0:N2}" -f (($VMClusterAllocatedGuestMemoryMB / (($VMClusterGuestList | Measure-Object).Count)))) GB/VM"
                    $report += $VMCluster | Select @{N="Cluster"; E={"$($_.Name)"}},
                                                   @{N="NumHosts"; E={"$($_.Summary.NumHosts)"}},
                                                   @{N="TotalCpuGHz"; E={"$("{0:N0}" -f ($VMClusterTotalCpu))"}},
                                                   @{N="TotalMemoryGB"; E={"$("{0:N0}" -f ($VMClusterTotalMemory))"}},
                                                   @{N="AllocatedMemoryGB"; E={"$("{0:N0}" -f ($VMClusterAllocatedGuestMemoryMB))"}},
                                                   @{N="% Allocated"; E={"$("{0:P0}" -f ($VMClusterAllocatedGuestMemoryMB / $VMClusterTotalMemory))"}},
                                                   @{N="NumGuests"; E={"$(($VMClusterGuestList | Measure-Object).Count)"}},
                                                   @{N="AvgGuestRam"; E={"$("{0:N2}" -f (($VMClusterAllocatedGuestMemoryMB / (($VMClusterGuestList | Measure-Object).Count))))"}}
                } else {
                    Write-Host "$(Get-Date -uformat %H:%M:%S) - $($VMCluster.Name) - $($VMCluster.Summary.NumHosts) Host(s) - $("{0:N0}" -f ($VMClusterTotalCpu)) GHz & $("{0:N2}" -f ($VMClusterTotalMemory)) GB - $(($VMClusterGuestList | Measure-Object).Count) Guest(s) - $("{0:N2}" -f ($VMClusterAllocatedGuestMemoryMB)) GB"
                    $report += $VMCluster | Select @{N="Cluster"; E={"$($_.Name)"}},
                                                   @{N="NumHosts"; E={"$($_.Summary.NumHosts)"}},
                                                   @{N="TotalCpuGHz"; E={"$("{0:N0}" -f ($VMClusterTotalCpu))"}},
                                                   @{N="TotalMemoryGB"; E={"$("{0:N0}" -f ($VMClusterTotalMemory))"}},
                                                   @{N="AllocatedMemoryGB"; E={"$("{0:N0}" -f ($VMClusterAllocatedGuestMemoryMB))"}},
                                                   @{N="% Allocated"; E={"$("{0:P0}" -f ($VMClusterAllocatedGuestMemoryMB / $VMClusterTotalMemory))"}},
                                                   @{N="NumGuests"; E={"$(($VMClusterGuestList | Measure-Object).Count)"}},
                                                   @{N="AvgGuestRam"; E={"0"}}
                }
            }
        }
    }
}

Write-Host "$(Get-Date -uformat %H:%M:%S) - $($i) of $(($VCList | Measure-Object).Count) VC(s) - Complete"

$report += "" | Select @{N="Cluster"; E={"Totals"}},
                       @{N="NumHosts"; E={"$($TotalNumHosts)"}},
                       @{N="TotalCpuGHz"; E={"$("{0:N0}" -f ($TotalCpu))"}},
                       @{N="TotalMemoryGB"; E={"$("{0:N0}" -f ($TotalMemory))"}},
                       @{N="AllocatedMemoryGB"; E={"$("{0:N0}" -f ($TotalMemoryAllocated))"}},
                       @{N="% Allocated"; E={"$("{0:P0}" -f ($TotalMemoryAllocated / $TotalMemory))"}},
                       @{N="NumGuests"; E={"$($TotalGuests)"}},
                       @{N="AvgGuestRam"; E={"$("{0:N2}" -f ($TotalMemoryAllocated / $TotalGuests))"}}

Write-Host "$(Get-Date -uformat %H:%M:%S) - Totals - $($TotalNumHosts) Host(s) - $("{0:N0}" -f ($TotalCpu)) GHz & $("{0:N0}" -f ($TotalMemory)) GB - $($TotalGuests) Guest(s) - $("{0:N2}" -f ($TotalMemoryAllocated)) GB w/ avg $("{0:N2}" -f ($TotalMemoryAllocated / $TotalGuests)) GB/VM"

$conclusionTime = Get-Date
Write-Host "$(Get-Date ($conclusionTime) -uformat %H:%M:%S) - Finished"
$totalTime = New-TimeSpan $initalTime $conclusionTime
Write-Host "$($totalTime.Hours):$($totalTime.Minutes):$($totalTime.Seconds) - Total Time"

$report | Out-GridView
$report | Export-Csv -Path "$filepath\$date$time-$filename.csv" -NoTypeInformation
