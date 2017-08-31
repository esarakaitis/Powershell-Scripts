#Author:        Eric Wannemacher
#Version:       200810220940
#Description:   Review database for unknowns and update their status.

param 
(
    [string] $master_file = $(throw "Must specify a file name to work with"),
    [switch] $h
)

# Source include files
. .\CompatibleDeviceIncludes.ps1

function ShowUsage
{
    Write-Host "CompatibleDeviceUpdater.ps1 -master_file <filename>"
    exit
}

function Get-Answer
{
    $result = $null
    
    while ($result -eq $null)
    {
        $answer = Read-Host "Virtualizable (v), Non-Virtualizable (n), or Unknown (u)"
        
        if ($answer -ne $null)
        {
            switch ($answer.ToLower())
            {
                "v" {$result = $TRUE}
                "n" {$result = $FALSE}
                "u" {$result = "unknown"}
                default {$result = $null}
            }
        }
    }
    
    $result
}

# Check arguments
if ($h) {ShowUsage}


# Load the known device list
$master_list = Import-DeviceList $master_file

# Update the status on any unknown items
foreach ($key in @($master_list.Keys))
{
    if ($master_list[$key].Virtualizable -eq "unknown")
    {
        Write-Host $key
        $virtualizable = Get-Answer
        $master_list[$key].Virtualizable = $virtualizable
    }
}

# Output the information in a friendlier object than a hash table.  This allows
# the output to be filtered easily using Where-Object or other commands/scripts.
$master_list.GetEnumerator() | ForEach-Object {$_.Value} | Export-Csv $master_file
