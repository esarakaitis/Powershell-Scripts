$myhost = Get-VMHost 
    
get-vmhost | New-Datastore -Nfs -Name nfs0 -Path /nfs0 -NfsHost nfs.idaho.local
