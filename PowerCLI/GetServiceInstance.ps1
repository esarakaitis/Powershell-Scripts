# Force load
[Reflection.Assembly]::LoadWithPartialName("vmware.vim")
 
$svcRef = new-object VMware.Vim.ManagedObjectReference 
$svcRef.Type = "ServiceInstance" 
$svcRef.Value = "ServiceInstance" 
$serviceInstance = get-view $svcRef
