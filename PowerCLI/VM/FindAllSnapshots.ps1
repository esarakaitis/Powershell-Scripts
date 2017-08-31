Get-VM | Get-Snapshot | `
	Select Name, @{Name="VM Name"; Expression={$_.VM.Name}},
                 @{Name="Date"; Expression={$_.created}}