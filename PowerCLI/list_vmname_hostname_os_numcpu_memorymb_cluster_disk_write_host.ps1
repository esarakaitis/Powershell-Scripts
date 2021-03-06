ForEach ($Cluster in Get-Cluster)
    {
        ForEach ($vm in ($cluster | Get-VM))
        {
            $VMView = $VM | Get-View
                     write-host   "VM Name" $VM.Name
                     write-host   "VM HostName" $VMView.Guest.HostName
                     write-host   "OS" $VMview.Guest.GuestFullName
                     write-host   "NumCPU" $VMview.Config.Hardware.NumCPU
                     write-host   "MemoryMB" $VMview.Config.Hardware.MemoryMB
                     write-host   "ClusterName" $Cluster.Name
            ForEach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | Where {$_.DeviceInfo.Label -match “SCSI Controller”}))
            {
                    ForEach ($VirtualDiskDevice in ($VMView.Config.Hardware.Device | Where {$_.ControllerKey -eq $VirtualSCSIController.Key}))
                    {
                       write-host "DiskInfo" $VirtualDiskDevice.DeviceInfo.Label ($VirtualDiskDevice.CapacityInKB / 1024KB)"GB"
                    }
            }
            
    }
}