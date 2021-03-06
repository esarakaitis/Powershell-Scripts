$Col = @()
foreach ($vmhost in get-vmhost) {
    $vmhostview = $vmhost | get-view
 "" | select-object (
  @{Name = "Name"; Expression = {$vmhostview.name}}, 
  @{Name = "Sockets"; Expression = {$vmhostview.Hardware.CpuInfo.NumCpuPackages}}, 
  @{Name = "Cores"; Expression = {$vmhostview.Hardware.CpuInfo.NumCpuCores}}, 
  @{Name = "MHz"; Expression = {$vmhostview.Summary.Hardware.CpuMhz}},
  @{Name = "Model"; Expression = {$vmhostview.Summary.Hardware.CpuModel}},
  @{Name = "Memory"; Expression = {$vmhostview.Summary.Hardware.MemorySize}}
  )
  $Col += $vmhostview   # Add output to collection
  }
  $Col | export-csv c:\hostinfo.csv