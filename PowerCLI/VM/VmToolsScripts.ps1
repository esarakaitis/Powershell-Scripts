$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo
$vmConfigSpec.Tools.AfterPowerOn = $true
$vmConfigSpec.Tools.AfterResume = $true
$vmConfigSpec.Tools.BeforeGuestStandby = $true
$vmConfigSpec.Tools.BeforeGuestShutdown = $true
$vmConfigSpec.Tools.SyncTimeWithHost = $true
$vmConfigSpec.Tools.ToolsUpgradePolicy = "Manual" # "UpgradeAtPowerCycle"

Get-VM | % { (Get-View $_.ID).ReconfigVM($vmConfigSpec)}
