$vms = Get-VM
foreach($vm in $vms){
  $pg = Get-VirtualPortGroup -VM $vm | select Name
 Write-Host $vm.Name $pg.name
  }
