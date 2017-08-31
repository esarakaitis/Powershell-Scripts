Get-View -ViewType VirtualMachine -Filter @{"Name" = "dom32-135"} | %{
     $vm = $_
     $_.Config.Hardware.Device | Select @{N="VM name";E={$vm.Name}},@{N="HW name";E={$_.GetType().Name}},@{N="Label";E={$_.DeviceInfo.Label}}
} | Export-Csv "C:\VM-HW.csv" -NoTypeInformation