# Object to hold device status
function DeviceCheck
{
    param
    (
        $description = $null,
        $virtualizable = $null,
        $comment = $null
    )
    
	$DC = New-Object PSObject
	$DC | Add-Member -MemberType NoteProperty -Name Description -Value $description
	$DC | Add-Member -MemberType NoteProperty -Name Virtualizable -Value $virtualizable
    $DC | Add-Member -MemberType NoteProperty -Name Comment -Value $comment
    $DC
}

# Function to import the master device list to use as a test
function Import-DeviceList
{
    param($filename=$NULL)
    
    $devices = Import-Csv $filename 
    $result = @{}
    
    $devices | ForEach-Object {
        $result.Add($_.Description, $_)
    }
    
    $result
}

function Export-DeviceList
{
    param
    (
        $list=$NULL,
        $filename=$NULL
    )
    
    $list.GetEnumerator() | ForEach-Object { $_.Value } | Export-Csv -NoTypeInformation $filename
}