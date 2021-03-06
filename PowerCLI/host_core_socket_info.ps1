Get-VMHost | %{Get-View $_.ID} | %{
  $name = $_.name
  $esx = "" | select NumCpuPackages, NumCpuCores, Hz, Memory
  $esx.NumCpuPackages = $_.Hardware.CpuInfo.NumCpuPackages 
  $esx.NumCpuCores = $_.Hardware.CpuInfo.NumCpuCores
  $esx | select-object @{Name = "Name"; Expression = {$name}}, @{Name = "Sockets"; Expression = {$esx.NumCpuPackages}}, @{Name = "Cores"; Expression = {$esx.NumCpuCores}}
  }