#Author:        Eric Wannemacher
#Version:       200810220940
#Description:   Combines an input stream of DeviceChecks into the master list.

param 
(
    [string] $filename = $(throw "Must specify a -filename argument"),
    [switch] $h = $false
)

BEGIN
{
# Source include files
. .\CompatibleDeviceIncludes.ps1

function ShowUsage
{
    Write-Host "CompatibleDeviceCombine.ps1 [-filename <filename>]"
    exit
}


if ($h) {ShowUsage}

# Load the known device list
$master_list = Import-DeviceList $filename
}

PROCESS
{
    if (!$master_list.ContainsKey($_.Description))
    {
        $master_list.Add($_.Description, $_)
    }
}

END
{
    $master_list.GetEnumerator() | ForEach-Object { $_.Value } | Export-Csv -NoTypeInformation $filename
}