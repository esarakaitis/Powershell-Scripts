$dstarget = "10000"
        $vdatastore = Get-Datastore | where { $_.Name  -notlike  "localvmfs*"  -and $_.Name -notlike "ISO*" -and  $_.FreeSpaceMB  -lt  $dstarget }
        		$vdatastore | Select-Object @{Name="Name"; Expression={$_.Name}},
								@{Name="FreeSpaceMB"; Expression={$_.FreeSpaceMB}},
								@{Name="CapacityMB"; Expression={$_.CapacityMB}}