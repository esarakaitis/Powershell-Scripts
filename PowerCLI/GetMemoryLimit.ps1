$report = @()
$vmMem = "-1"
foreach ($vm in Get-VM)
{
$vmObj = $vm | Get-View
$vmMemLimit = $vmObj.config.memoryAllocation.limit
if ($vmMemLimit -ne $vmMem)
{
$data = write-host $vmObj.Name $vmMemLimit
}
}
$report =+ $data
$report