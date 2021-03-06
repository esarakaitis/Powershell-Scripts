get-vmhost vdiesx05.ccs.local | Get-VM | % {Get-View $_.ID} |
    % {$spec = new-object VMware.Vim.VirtualMachineConfigSpec;
        $spec.memoryAllocation = New-Object VMware.Vim.ResourceAllocationInfo;
        $spec.memoryAllocation.Shares = New-Object VMware.Vim.SharesInfo;
        $spec.memoryAllocation.Shares.Level = "normal";
        $spec.memoryAllocation.Limit = -1;
        $spec.memoryAllocation.Reservation = 16384;
        Get-View($_.ReconfigVM_Task($spec))}