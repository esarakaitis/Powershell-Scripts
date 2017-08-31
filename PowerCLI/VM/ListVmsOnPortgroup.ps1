get-cluster "Enterprise" | get-vm | % { $vm = $_; $vm | get-networkadapter | where {$_.networkname -eq "VLAN113"} | Select-Object @{Name="VmName"; Expression={$vm.name}}, Name, NetworkName} 