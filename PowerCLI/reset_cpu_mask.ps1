Function Reset-VMCPUMask ($vm) {

    $vmspec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $vmspec.files = New-Object VMware.Vim.VirtualMachineFileInfo
    $vmspec.cpuFeatureMask = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec[] (4)
    $vmspec.cpuFeatureMask[0] = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec
    $vmspec.cpuFeatureMask[0].operation = "remove"
    $vmspec.cpuFeatureMask[0].info = New-Object VMware.Vim.HostCpuIdInfo
    $vmspec.cpuFeatureMask[0].info.level = 1

    $vmspec.cpuFeatureMask[1] = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec
    $vmspec.cpuFeatureMask[1].operation = "remove"
    $vmspec.cpuFeatureMask[1].info = New-Object VMware.Vim.HostCpuIdInfo
    $vmspec.cpuFeatureMask[1].info.level = 1
    $vmspec.cpuFeatureMask[1].info.vendor = "amd"

    $vmspec.cpuFeatureMask[2] = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec
    $vmspec.cpuFeatureMask[2].operation = "remove"
    $vmspec.cpuFeatureMask[2].info = New-Object VMware.Vim.HostCpuIdInfo
    $vmspec.cpuFeatureMask[2].info.level = -2147483647

    $vmspec.cpuFeatureMask[3] = New-Object VMware.Vim.VirtualMachineCpuIdInfoSpec
    $vmspec.cpuFeatureMask[3].operation = "remove"
    $vmspec.cpuFeatureMask[3].info = New-Object VMware.Vim.HostCpuIdInfo
    $vmspec.cpuFeatureMask[3].info.level = -2147483647
    $vmspec.cpuFeatureMask[3].info.vendor = "amd"

    $vmView = Get-View -Id $vm.id
    $vmView.ReconfigVM_Task($vmspec)


}

Reset-VMCPUMask (get-vm vmname)
