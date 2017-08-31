$dsView = Get-Datastore -Name "entprf01_vmfs_linux_vol01" | Get-View -Property Name

Get-VM "authdemo04" | % {
$vmView = $_ | Get-View -Property Name

$spec = New-Object VMware.Vim.VirtualMachineRelocateSpec
$spec.datastore =  $dsView.MoRef
$spec.transform = "sparse"

$vmView.RelocateVM($spec, $null)
}

