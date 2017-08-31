foreach ($vm in get-cluster "vmvdx cluster" | get-vm)
{
Get-VM $vm | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemReservationMB $vm.memorymb
}
