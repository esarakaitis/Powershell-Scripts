$VMs = Get-VM
foreach ($VM in $VMs){
	$VM = Get-View $VM.ID
	$nm = $VM.name
    $hn = $VM.guest.hostname 
    $vm | select @{Name = "Name"; Expression = {$nm}}, @{Name = "Hostname"; Expression = {$hn}}
    }
