$esxImpl = Get-VMHost
$esx = Get-View $esxImpl.ID
$esxmemMgr = Get-View $esx.ConfigManager.MemoryManager
$consolemem = 512 * 1MB
$esxmemMgr.ReconfigureServiceConsoleReservation($consoleMem)