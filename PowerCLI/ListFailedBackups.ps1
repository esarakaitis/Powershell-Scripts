$clusname = "citrix"
get-cluster $clusname | get-vm | Where-Object {$_.Description -match "Error"} |
Select-Object @{Name="Name"; Expression={$_.name}},
@{Name="Notes"; Expression={$_.Description}}