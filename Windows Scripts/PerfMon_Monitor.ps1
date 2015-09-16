
$servers = get-content c:\comp.txt


foreach ($server in $servers)
            {
                $cache="\cache\copy read hits %"
                $iops="\Process(StreamProcess)\IO Data Operations/sec"
                get-counter -computername $server -counter $cache,$iops  -sampleinterval 5 -maxsamples 5  | % { $_.counterSamples } | sort path | ft -Wrap –AutoSize >> c:\cachetest.txt
            }


Second way



foreach ($server in $servers)
            {
                $iops="\Process(StreamProcess)\IO Data Operations/sec"
                $cache="\cache\copy read hits %"  
                $cachedata=get-counter -computername $server -counter $cache  -sampleinterval 1 -maxsamples 1  | % { $_.counterSamples}
                $iopdata=get-counter -computername $server -counter $iops  -sampleinterval 1 -maxsamples 1  | % { $_.counterSamples}
                "" | select-object @{Name="Name"; Expression={$Server}},
                                    @{Name="Cache"; Expression={$Cachedata.Cookedvalue}},
                                    @{Name="Iops"; Expression={$iopdata.Cookedvalue}}
            }