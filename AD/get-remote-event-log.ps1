$pcs = get-content c:\pvs.txt
$date = (get-date).AddDays(-1)
$datetoday = get-date
foreach ($pc in $pcs)
        {
            $pverrors = get-eventlog -computer $pc -log Application -source StreamProcess -entrytype Error -after $date -before $datetoday -newest 5 | where {$_.eventID -eq 11}
            
                foreach ($pverror in $pverrors) { "" | select-object @{Name="Hostname"; Expression={$pc}}, 
                                                                        @{Name="Time"; Expression={$pverror.timewritten}},
                                                                        @{Name="Message"; Expression={$pverror.message}} | export-csv c:\results.csv
            }
        }
.\sendmail.ps1
echo "task complete, please check your email"