$initalTime = Get-Date
$filepath = "C:\temp"
$filename = "forecast.xlsx"
$date = Get-Date ($initalTime) -uformat %Y%m%d
$time = Get-Date ($initalTime) -uformat %H%M

$VCList = @("VCENTER_HOSTNAME_OR_IP")


if ((($VCList | Measure-Object).Count) -gt 0) {
    ForEach ($VC in ($VCList | Sort-Object)) {
        Connect-VIServer -Server $VC | out-Null
    }
}

function Get-VMClusterHostsNames ($VMCluster) {
    $VMClusterHostNames = Get-View -Server $VC -ViewType ClusterComputeResource -Filter @{"Name"=$VMCluster.Name} | Select-Object -ExpandProperty Host | Select-Object -ExpandProperty Value
    $VMHostNameLoopCount = 0
    $VMHostNameList = ""
    if (($VMClusterHostNames | Measure-Object).Count -gt 0) {
        foreach ($VMHostName in $VMClusterHostNames) {
            $VMHostNameLoopCount++
            if ($VMHostNameLoopCount -gt 1) {
                $VMHostNameList += "|^"+$VMHostName+"$"
            } else {
                $VMHostNameList += "^"+$VMHostName+"$"
            }
        }
    }
    return $VMHostNameList
}


Write-Host "$(Get-Date ($initalTime) -uformat %H:%M:%S) - Starting"

#-----------------------------------------------------
function Release-Ref ($ref) {
    ([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers() 
}
#-----------------------------------------------------

[reflection.assembly]::loadWithPartialname("Microsoft.Office.Interop.Excel") | out-Null
$xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
$objExcel = new-object -comobject excel.application
#$objExcel.Visible = $True
$objWorkbook = $objExcel.Workbooks.Add()

while ($objWorkbook.Worksheets.Count -ne $VCList.Count) {
    if ($objWorkbook.Worksheets.Count -gt $VCList.Count) {
        $objWorkbook.Worksheets.Item($objWorkbook.Worksheets.Count).Delete()
    } elseif ($objWorkbook.Worksheets.Count -lt $VCList.Count) {
        $objWorkbook.Worksheets.Add() | out-Null
    }
}

Write-Host "$(Get-Date -uformat %H:%M:%S) - $(($VCList | Measure-Object).Count) VC(s) acquired"

$i = 0
if ((($VCList | Measure-Object).Count) -gt 0) {
    ForEach ($VC in ($VCList | Sort-Object)) {
        $i++
        $rowCount = 1
        $objWorksheet = $objWorkbook.Worksheets.Item($i)
        $objWorksheet.Name = [regex]::Matches($VC, "(^[^.]+)")
        Write-Host "$(Get-Date -uformat %H:%M:%S) - $($i) of $(($VCList | Measure-Object).Count) - $($VC)"
        #setup columns
        $clusterColumns = @("Cluster Name", "Num Guests", "Num Hosts", "Total Cpu Capacity GHz", "Total Cpu Demand GHz", "% CPU Demand", "Total Memory Capacity GB", "Total Effective Memory GB", "Allocated Memory GB", "% Allocated", "% Allocated N-1", "Avg Allocated Guest Ram GB", "Estimated Allocated More Guests", "Host Memory Usage GB", "% Host Memory Used", "% Host Memory Used N-1", "Avg Host Used Guest Ram GB", "Estimated Host Used More Guests")
        foreach ($clusterColumn in $clusterColumns) {
            $j = 0..($clusterColumns.length - 1) | ? {$clusterColumns[$_] -eq $clusterColumn}
            $objWorksheet.Cells.Item($rowCount,($j+1)).Value() = "$clusterColumn"
        }
        
        $VMClusterList = Get-View -Server $VC -ViewType ClusterComputeResource | Sort-Object Name
        
        if (($VMClusterList | Measure-Object).Count -gt 0) {
            ForEach ($VMCluster in $VMClusterList) {
                $rowCount++
                #ClusterName
                $objWorksheet.Cells.Item($rowCount,1).Value() = "$($VMCluster.Name)"
                #NumHosts
                $objWorksheet.Cells.Item($rowCount,3).Value() = "$($VMCluster.Summary.NumHosts)"
                #TotalCpuCapacityGHz
                $objWorksheet.Cells.Item($rowCount,4).Formula = "=($($VMCluster.Summary.TotalCpu)/1000)"
                #TotalMemoryCapacityGB
                $objWorksheet.Cells.Item($rowCount,7).Formula = "=($($VMCluster.Summary.TotalMemory)/(1024^3))"
                #TotalEffectiveMemoryGB
                $objWorksheet.Cells.Item($rowCount,8).Formula = "=($($VMCluster.Summary.EffectiveMemory)/1024)"
                $VMHostNameList = Get-VMClusterHostsNames $VMCluster
                if ($VMHostNameList.Length -gt 0) {
                    $VMClusterGuestList = Get-View -Server $VC -ViewType VirtualMachine -Filter @{"Runtime.Host"=$VMHostNameList; "Runtime.PowerState"="poweredOn"; "Config.Template"="False"} | Sort-Object Name
                    if (($VMClusterGuestList | Measure-Object).Count -gt 0) {
                        $VMClusterOverallCpuDemand = ($VMClusterGuestList | Select-Object -ExpandProperty Summary | Select-Object -ExpandProperty QuickStats | Measure-Object -Property OverallCpuDemand -Sum).Sum
                        $VMClusterAllocatedGuestMemoryMB = ($VMClusterGuestList | Select-Object -ExpandProperty Config | Select-Object -ExpandProperty Hardware | Measure-Object -Property MemoryMB -Sum).Sum
                        $VMClusterHostMemoryUsage = ($VMClusterGuestList | Select-Object -ExpandProperty Summary | Select-Object -ExpandProperty QuickStats | Measure-Object -Property HostMemoryUsage -Sum).Sum
                        #$VMClusterGuestMemoryUsage = ($VMClusterGuestList | Select-Object -ExpandProperty Summary | Select-Object -ExpandProperty QuickStats | Measure-Object -Property GuestMemoryUsage -Sum).Sum
                        #NumGuests
                        $objWorksheet.Cells.Item($rowCount,2).Value() = "$(($VMClusterGuestList | Measure-Object).Count)"
                        #TotalCpuDemandGHz
                        $objWorksheet.Cells.Item($rowCount,5).Formula = "=($($VMClusterOverallCpuDemand)/(1000))"
                        #AllocatedMemoryGB
                        $objWorksheet.Cells.Item($rowCount,9).Formula = "=($($VMClusterAllocatedGuestMemoryMB)/(1024))"
                        #HostMemoryUsageGB
                        $objWorksheet.Cells.Item($rowCount,14).Formula = "=($($VMClusterHostMemoryUsage)/(1024))"
                    } else {
                        $objWorksheet.Cells.Item($rowCount,2).Value() = "0"
                        $objWorksheet.Cells.Item($rowCount,5).Value() = "0"
                        $objWorksheet.Cells.Item($rowCount,9).Value() = "0"
                        $objWorksheet.Cells.Item($rowCount,14).Value() = "0"
                    }
                } else {
                    $objWorksheet.Cells.Item($rowCount,2).Value() = "0"
                    $objWorksheet.Cells.Item($rowCount,5).Value() = "0"
                    $objWorksheet.Cells.Item($rowCount,9).Value() = "0"
                    $objWorksheet.Cells.Item($rowCount,14).Value() = "0"
                }
                #% CPU Demand
                $objWorksheet.Cells.Item($rowCount,6).Formula = "=IF(D$rowCount=0, 0, E$rowCount/D$rowCount)"
                #% Allocated
                $objWorksheet.Cells.Item($rowCount,10).Formula = "=IF(H$rowCount=0, 0, I$rowCount/H$rowCount)"
                #% Allocated N-1
                $objWorksheet.Cells.Item($rowCount,11).Formula = "=IF(H$rowCount=0, 0, I$rowCount/(H$rowCount-(H$rowCount/C$rowCount)))"
                #Avg Allocated Guest Ram GB
                $objWorksheet.Cells.Item($rowCount,12).Formula = "=IF(B$rowCount=0, 0, I$rowCount/B$rowCount)"
                #Estimated Allocated More Guests
                $objWorksheet.Cells.Item($rowCount,13).Formula = "=IF(B$rowCount=0, 0, ((((H$rowCount-(H$rowCount/C$rowCount))*(0.9))-I$rowCount)/L$rowCount))"
                #% Host Memory Used
                $objWorksheet.Cells.Item($rowCount,15).Formula = "=IF(H$rowCount=0, 0, N$rowCount/H$rowCount)"
                #% Host Memory Used N-1
                $objWorksheet.Cells.Item($rowCount,16).Formula = "=IF(H$rowCount=0, 0, N$rowCount/(H$rowCount-(H$rowCount/C$rowCount)))"
                #Avg Host Used Guest Ram GB
                $objWorksheet.Cells.Item($rowCount,17).Formula = "=IF(B$rowCount=0, 0, N$rowCount/B$rowCount)"
                #Estimated Host Used More Guests
                $objWorksheet.Cells.Item($rowCount,18).Formula = "=IF(B$rowCount=0, 0, ((((H$rowCount-(H$rowCount/C$rowCount))*(0.9))-N$rowCount)/Q$rowCount))"
            }
        }
        
        $endRow = $objWorksheet.UsedRange.Rows.Count
        $rowCount = $rowCount+2
        $objWorksheet.Cells.Item($rowCount,1).Value() = "Totals"
        $objWorksheet.Cells.Item($rowCount,2).Formula = "=SUM(B2:B$endRow)"
        $objWorksheet.Cells.Item($rowCount,3).Formula = "=SUM(C2:C$endRow)"
        $objWorksheet.Cells.Item($rowCount,4).Formula = "=SUM(D2:D$endRow)"
        $objWorksheet.Cells.Item($rowCount,5).Formula = "=SUM(E2:E$endRow)"
        $objWorksheet.Cells.Item($rowCount,6).Formula = "=IF(D$rowCount=0, 0, E$rowCount/D$rowCount)"
        $objWorksheet.Cells.Item($rowCount,7).Formula = "=SUM(G2:G$endRow)"
        $objWorksheet.Cells.Item($rowCount,8).Formula = "=SUM(H2:H$endRow)"
        $objWorksheet.Cells.Item($rowCount,9).Formula = "=SUM(I2:I$endRow)"
        $objWorksheet.Cells.Item($rowCount,10).Formula = "=IF(H$rowCount=0, 0, I$rowCount/H$rowCount)"
        $objWorksheet.Cells.Item($rowCount,11).Formula = "=IF(H$rowCount=0, 0, I$rowCount/(H$rowCount-(H$rowCount/C$rowCount)))"
        $objWorksheet.Cells.Item($rowCount,12).Formula = "=IF(B$rowCount=0, 0, I$rowCount/B$rowCount)"
        $objWorksheet.Cells.Item($rowCount,13).Formula = "=IF(B$rowCount=0, 0, ((((H$rowCount-(H$rowCount/C$rowCount))*(0.9))-I$rowCount)/L$rowCount))"
        $objWorksheet.Cells.Item($rowCount,14).Formula = "=SUM(N2:N$endRow)"
        $objWorksheet.Cells.Item($rowCount,15).Formula = "=IF(H$rowCount=0, 0, N$rowCount/H$rowCount)"
        $objWorksheet.Cells.Item($rowCount,16).Formula = "=IF(H$rowCount=0, 0, N$rowCount/(H$rowCount-(H$rowCount/C$rowCount)))"
        $objWorksheet.Cells.Item($rowCount,17).Formula = "=IF(B$rowCount=0, 0, N$rowCount/B$rowCount)"
        $objWorksheet.Cells.Item($rowCount,18).Formula = "=IF(B$rowCount=0, 0, ((((H$rowCount-(H$rowCount/C$rowCount))*(0.9))-N$rowCount)/Q$rowCount))"
        
        $endRow = $objWorksheet.UsedRange.Rows.Count
        
        $objWorksheet.range("B2:B$endRow").NumberFormat = "0"
        $objWorksheet.range("C2:C$endRow").NumberFormat = "0"
        $objWorksheet.range("D2:D$endRow").NumberFormat = "0"
        $objWorksheet.range("E2:E$endRow").NumberFormat = "0"
        $objWorksheet.range("F2:F$endRow").NumberFormat = "0%"
        $objWorksheet.range("G2:G$endRow").NumberFormat = "0"
        $objWorksheet.range("H2:H$endRow").NumberFormat = "0"
        $objWorksheet.range("I2:I$endRow").NumberFormat = "0"
        $objWorksheet.range("J2:J$endRow").NumberFormat = "0%"
        $objWorksheet.range("K2:K$endRow").NumberFormat = "0%"
        $objWorksheet.range("L2:L$endRow").NumberFormat = "0.00"
        $objWorksheet.range("M2:M$endRow").NumberFormat = "0"
        $objWorksheet.range("N2:N$endRow").NumberFormat = "0"
        $objWorksheet.range("O2:O$endRow").NumberFormat = "0%"
        $objWorksheet.range("P2:P$endRow").NumberFormat = "0%"
        $objWorksheet.range("Q2:Q$endRow").NumberFormat = "0.00"
        $objWorksheet.range("R2:R$endRow").NumberFormat = "0"
        
        $objWorksheet.range("1:1").VerticalAlignment = $xlConstants::xlBottom
        $objWorksheet.range("1:1").WrapText = $True
        $objWorksheet.range("1:1").Orientation = "90"
        $objWorksheet.range("1:1").ReadingOrder = $xlConstants::xlContext
        
        $objWorksheet.range("K2:K$endRow").FormatConditions.AddColorScale(3)  | out-Null
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item($objWorksheet.range("K2:K$endRow").FormatConditions.Count).SetFirstPriority  | out-Null
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).Type = 0
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).Value = .6
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).FormatColor.Color = 8109667
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).FormatColor.TintAndShade = 0
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).Type = 0
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).Value = .75
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).FormatColor.Color = 8711167
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).FormatColor.TintAndShade = 0
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).Type = 0
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).Value = .9
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).FormatColor.Color = 7039480
        $objWorksheet.range("K2:K$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).FormatColor.TintAndShade = 0
        
        $objWorksheet.range("P2:P$endRow").FormatConditions.AddColorScale(3)  | out-Null
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item($objWorksheet.range("P2:P$endRow").FormatConditions.Count).SetFirstPriority  | out-Null
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).Type = 0
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).Value = .6
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).FormatColor.Color = 8109667
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(1).FormatColor.TintAndShade = 0
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).Type = 0
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).Value = .75
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).FormatColor.Color = 8711167
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(2).FormatColor.TintAndShade = 0
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).Type = 0
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).Value = .9
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).FormatColor.Color = 7039480
        $objWorksheet.range("P2:P$endRow").FormatConditions.Item(1).ColorScaleCriteria.Item(3).FormatColor.TintAndShade = 0
        
        $VMDatastoreList = Get-View -Server $VC -ViewType Datastore -Filter @{"Summary.Type"="VMFS"; "Summary.MultipleHostAccess"="True"} | Sort-Object Name
        if (($VMDatastoreList | Measure-Object).Count -gt 0) {
            $rowCount = $rowCount+4
            $datastoreRow = $rowCount +1
            $datastoreColumns = @("DatastoreName", "TotalCapacityGB", "FreeSpaceGB", "% Free")
            ForEach ($datastoreColumn in $datastoreColumns) {
                $j = 0..($datastoreColumns.length - 1) | ? {$datastoreColumns[$_] -eq $datastoreColumn}
                $objWorksheet.Cells.Item($rowCount,($j+1)).Value() = "$datastoreColumn"
            }
            ForEach ($VMDatastore in $VMDatastoreList) {
                $rowCount++
                $objWorksheet.Cells.Item($rowCount,1).Value() = "$($VMDatastore.Name)"
                $objWorksheet.Cells.Item($rowCount,2).Formula = "=($($VMDatastore.Summary.Capacity)/(1024^3))"
                $objWorksheet.Cells.Item($rowCount,3).Formula = "=($($VMDatastore.Summary.FreeSpace)/(1024^3))"
                $objWorksheet.Cells.Item($rowCount,4).Formula = "=(C$($rowCount)/B$($rowCount))"
            }
            $endRow = $objWorksheet.UsedRange.Rows.Count
            $rowCount = $rowCount+2
            $objWorksheet.Cells.Item($rowCount,1).Value() = "Totals"
            $objWorksheet.Cells.Item($rowCount,2).Formula = "=SUM(B$($datastoreRow):B$($endRow))"
            $objWorksheet.Cells.Item($rowCount,3).Formula = "=SUM(C$($datastoreRow):C$($endRow))"
            $objWorksheet.Cells.Item($rowCount,4).Formula = "=(C$($rowCount)/B$($rowCount))"
            $endRow = $objWorksheet.UsedRange.Rows.Count
            $objWorksheet.range("C$($datastoreRow):C$($endRow)").NumberFormat = "0"
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").NumberFormat = "0%"
            $objWorksheet.range("B$($datastoreRow):B$($endRow)").NumberFormat = "0"
            
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.AddColorScale(3)  | out-Null
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item($objWorksheet.range("D2:D$endRow").FormatConditions.Count).SetFirstPriority  | out-Null
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(1).Type = 0
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(1).Value = .1
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(1).FormatColor.Color = 7039480
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(1).FormatColor.TintAndShade = 0
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(2).Type = 0
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(2).Value = .15
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(2).FormatColor.Color = 8711167
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(2).FormatColor.TintAndShade = 0
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(3).Type = 0
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(3).Value = .2
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(3).FormatColor.Color = 8109667
            $objWorksheet.range("D$($datastoreRow):D$($endRow)").FormatConditions.Item(1).ColorScaleCriteria.Item(3).FormatColor.TintAndShade = 0
        }
        $objWorksheet.UsedRange.EntireColumn.HorizontalAlignment = $xlConstants::xlRight
        $objWorksheet.Cells.Item(1,1).EntireColumn.HorizontalAlignment = $xlConstants::xlLeft
        $objWorksheet.UsedRange.EntireColumn.AutoFit() | out-Null
    }
}

$objWorkbook.SaveAs("c:\temp\$($date)$($time)-$($filename)")

$objExcel.Visible = $True
Release-Ref($objWorksheet) | out-Null
Release-Ref($objWorkbook) | out-Null
Release-Ref($objExcel) | out-Null

$conclusionTime = Get-Date
Write-Host "$(Get-Date ($conclusionTime) -uformat %H:%M:%S) - Finished"
$totalTime = New-TimeSpan $initalTime $conclusionTime
Write-Host "$($totalTime.Hours):$($totalTime.Minutes):$($totalTime.Seconds) - Total Time"