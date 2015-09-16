$outputArray = @()
$servers = get-content c:\comp.txt
foreach ($server in $servers)
{
$iops = "\Process(StreamProcess)\IO Data Operations/sec"
$cache = "\cache\copy read hits %" 
$cachedata = get-counter -computername $server -counter $cache -sampleinterval 1 -maxsamples 1 | % { $_.counterSamples}
$iopdata = get-counter -computername $server -counter $iops -sampleinterval 1 -maxsamples 1 | % { $_.counterSamples}
$data = @{server=$server;cacheCookedValue=($Cachedata.Cookedvalue);iopCookedValue=($iopdata.Cookedvalue)}
$objData = New-Object PSObject -Property $data
$outputArray += $objData
}

#$outputArray | select-object server, cacheCookedValue, iopCookedValue

$outputArray | ft @{e={$_.server};l="Server"},@{e={$_.cacheCookedValue};l="Cache"},@{e={$_.iopCookedValue};l="Iops"} -auto