$myCol = @()
ForEach ($Cluster in Get-Cluster)
    {
        ForEach ($vm in ($cluster | Get-VM))
        {
            $VMView = $VM | Get-View
            ForEach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | Where {$_.DeviceInfo.Label -match “SCSI Controller”}))
            {
                    ForEach ($VirtualDiskDevice in ($VMView.Config.Hardware.Device | Where {$_.ControllerKey -eq $VirtualSCSIController.Key}))
                    {
                        $VMSummary = “” | Select VM, HostName, DiskName, DiskSizeGB, OS, NumCPU, Memory, Cluster
                        $VMSummary.VM = $VM.Name
                        $VMSummary.HostName = $VMView.Guest.HostName
                        $VMSummary.DiskName = $VirtualDiskDevice.DeviceInfo.Label
                        $VMSummary.DiskSizeGB = $VirtualDiskDevice.CapacityInKB / 1024KB
                        $VMSummary.OS = $VMview.Guest.GuestFullName
                        $VMSummary.NumCPU = $VMview.Config.Hardware.NumCPU
                        $VMSummary.Memory = $VMview.Config.Hardware.MemoryMB
                        $VMSummary.Cluster = $Cluster.name
                        $myCol += $VMSummary
                    }
            }
    }
}
$myCol #| out-gridview