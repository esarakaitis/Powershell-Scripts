$baseline = "Approved Host Updates"
$vmhosts = Get-Cluster "1RP Lab" | Get-VMhost
$vmhosts | Get-Compliance | Where-Object {$_.Baseline.Name -eq $baseline}  | `
    Select-Object  @{Name="Name"; Expression={$_.entity}}, `
    @{Name="Baseline"; Expression={$_.Baseline.Name}},  `
    @{Name="Status"; Expression={$_.status}} 
