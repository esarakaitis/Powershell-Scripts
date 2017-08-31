$VMlist = get-datastore vsandatastore | get-vm
$StoragePolicy = "vSAN"
foreach ($VM in $VMlist)
    {
    Get-VM -Name $VM | Set-SpbmEntityConfiguration -StoragePolicy $StoragePolicy
    }