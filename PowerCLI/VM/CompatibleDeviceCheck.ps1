#Author:        Eric Wannemacher
#Version:       200810220940
#Description:   Compares the hardware on a target system against a known
#               device database.

param 
(
    [string] $computer = $null,
    [string] $file = $null,
    [string] $master_file = "VirtualizableDevices.csv",
    [switch] $h
)

# Source include files
. .\CompatibleDeviceIncludes.ps1

function ShowUsage
{
    Write-Host "CompatibleDeviceCheck.ps1 (-computer computername | -file filename) [-master_file <filename>]"
    exit
}


if ($h) {ShowUsage}
if (!$computer -and !$file) {ShowUsage}

# Load the known device list
$master_list = Import-DeviceList $master_file

# Load the target system device list
$test_list = @{}

if ($computer)
{
    Get-WmiObject -computername $computer -query "Select Description FROM Win32_PNPEntity" | Select-Object Description | Sort-Object Description -unique | ForEach-Object {
        $test_list.Add($_.Description, "unknown")
    }
}
else
{
    Import-Csv $file | ForEach-Object {
        $test_list.Add($_.Description, "unknown")
    }
}

# Update the status for known devices
foreach ($description in @($test_list.Keys))
{
	if ($master_list.ContainsKey($description))
    {
        $test_list[$description] = $master_list[$description].Virtualizable
    }
}

# Output the information in a friendlier object than a hash table.  This allows
# the output to be filtered easily using Where-Object or other commands/scripts.
$test_list.GetEnumerator() | ForEach-Object { DeviceCheck $_.Key $_.Value ""}
