#FQDNs or IP addresses of ESXi Hosts to Configure
#Enclose each host in quotes and separate with a comma.
#Example: $ESXiHosts = "192.168.1.1","192.168.1.2"
$ESXiHosts = get-vmhost


$targets = "10.99.17.200", "10.99.18.200"

foreach ($esx in $ESXiHosts) {

  # Enable Software iSCSI Adapter on each host
  Write-Host "Enabling Software iSCSI Adapter on $esx ..."
  Get-VMHostStorage -VMHost $esx | Set-VMHostStorage -SoftwareIScsiEnabled $True 

#  # Just a sleep to wait for the adapter to load
  Write-Host "Sleeping for 30 Seconds..." -ForegroundColor Green
  Start-Sleep -Seconds 30
  Write-Host "OK Here we go..." -ForegroundColor Green
  Write-Host "Adding iSCSI SendTargets..." -ForegroundColor Green

  $hba = $esx | Get-VMHostHba -Type iScsi | Where {$_.Model -eq "iSCSI Software Adapter"}

  foreach ($target in $targets) {

     # Check to see if the SendTarget exist, if not add it
     if (Get-IScsiHbaTarget -IScsiHba $hba -Type Send | Where {$_.Address -cmatch $target}) {
        Write-Host "The target $target does exist on $esx" -ForegroundColor Green
     }
     else {
        Write-Host "The target $target doesn't exist on $esx" -ForegroundColor Red
        Write-Host "Creating $target on $esx ..." -ForegroundColor Yellow
        New-IScsiHbaTarget -IScsiHba $hba -Address $target        
     }

  }

}
Write "`n Done with $ESXiHosts"

Write-Host "Done! Now go manually add the iSCSI vmk bindings to the Software iSCSI Adapter and Resan." -ForegroundColor Green