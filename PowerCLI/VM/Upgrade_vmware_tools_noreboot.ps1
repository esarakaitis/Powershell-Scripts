$starttime = get-date
$GuestCred = Get-Credential
$OldTools = Get-View -ViewType "VirtualMachine" `
    -Property Guest,name `
    -filter @{
        "Guest.GuestFamily"="windowsGuest";
        "Guest.ToolsStatus"="ToolsOld";
        "Guest.GuestState"="running"
    }
 
Foreach ($VM in $OldTools) {
    # Mount the tools CD
    $VM.MountToolsInstaller()
 
    # Get the drive letter for the CD Drive tools is mounted in
    $DrvLetter = Get-WmiObject Win32_CDROMDrive -ComputerName $VM.name -Credential $GuestCred | 
        Where-Object {$_.VolumeName -match "VMware Tools"} | 
        Select-Object -ExpandProperty Drive
 
    # our update cmd
    $cmd = "$($DrvLetter)setup.exe /S /v`"/qn REBOOT=ReallySuppress REINSTALLMODE=vomus REINSTALL=ALL`""
 
    # Create a new process on the VM, and execute setup
    $go = Invoke-WMIMethod -path win32_process `
        -Name Create `
        -Credential $GuestCred `
        -ComputerName $VM.Name `
        -ArgumentList $cmd
 
    # If we sucessfully spawned an upgrade wait for it to finish
    IF ($go.ReturnValue -eq 0) 
    {
        $i=0
        While ($VM.Guest.ToolsStatus -ne 'toolsOk')
        {
            Start-Sleep -Seconds 1
            $VM.UpdateViewData("Guest")
            if ($I -gt 120)
            {
                Write-Warning "$($VM.name) appears to have hung, please investigate!"
                break
            }
            $i++
        }
        $vm.UnmountToolsInstaller()
        Write-verbose "$($VM.Name) Successfully updated"
    } 
    else 
    {
        Write-Warning "error $(go.ReturnValue) triggering tools install on $($VM.name). "
        $vm.UnmountToolsInstaller()
    }
}
$processed = $oldTools.count - (Get-View -ViewType "VirtualMachine" `
    -Property Guest,name `
    -filter @{
        "Guest.GuestFamily"="windowsGuest";
        "Guest.ToolsStatus"="ToolsOld";
        "Guest.GuestState"="running"
    }).count
$ts = New-TimeSpan -Start $starttime
write-host ("{0} out of {1} vm's were updated in {2}.{3} Min" -f $processed, $oldTools.count, $ts.Minutes,$ts.Seconds)