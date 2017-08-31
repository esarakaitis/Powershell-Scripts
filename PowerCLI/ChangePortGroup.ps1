#
# Usage:     IsPingable <hostname> | <ip>
# Returns:   $true if pingable, $false otherwise
Function IsPingable
{
    Param
    (
        [String]$target = $(throw "Must specify a target to ping.")
    )
    
    $ping = new-object System.Net.NetworkInformation.Ping
    trap [Exception] {continue;}
    $status = $false
        
    # Process any arguments given as if this were a command
    if ($ping.Send($target).status -eq "Success" )
    {
        $status = $true
    }
    
    $status
}

#####    MAINLINE    #####

###  SET PARAMETERS HERE ####
$FromNetwork = "bond0-10.21.205"
$ToNetwork = "10.21.205.0_Team01"
$vmCluster = "Roanoke"

###  Check if the from and to port group names are available on hosts in the cluster.

$terminate = 0
$ClusterHosts = get-cluster $vmCluster | get-vmhost
$ClusterHosts
if ( $ClusterHosts.length -ne $null ) {
     for ($i = 0; $i -lt $ClusterHosts.length; $i++) {
	"Verifying port groups on " + $ClusterHosts[$i].name ;
	$view = get-view $ClusterHosts[$i].id ;
	$pg = $view.config.network.portgroup | ? {$_.key.contains($FromNetwork)} ; if ($pg.key -ne $null) {"  From Port Group Found"} else {"  From Port Group NOT Found" ; $terminate = 1 } 
	$pg = $view.config.network.portgroup | ? {$_.key.contains($ToNetwork)} ; if ($pg.key -ne $null) {"  To Port Group Found"} else {"  To Port Group NOT Found" ; $terminate = 1 } }
     }
else {
	$view = get-view $ClusterHosts.id ;
	$pg = $view.config.network.portgroup | ? {$_.key.contains($FromNetwork)} ; if ($pg.key -ne $null) {"  From Port Group Found"} else {"  From Port Group NOT Found" ; $terminate = 1 } 
	$pg = $view.config.network.portgroup | ? {$_.key.contains($ToNetwork)} ; if ($pg.key -ne $null) {"  To Port Group Found"} else {"  To Port Group NOT Found" ; $terminate = 1 } 
     } 

### If from and to network are NOT configuref on all host in cluster, teminate the script.
	
If  ( $terminate -eq 1 ) {"Script Terminated" ; exit }


$guests = get-cluster $vmCluster| get-vm 

$guests |   % {
		$vmName = $_.name ;
		$vmHostName = $_.guest.hostname; if ($vmHostName -eq $null) { $vmHostName = "NO HOST NAME"} else {$vmHostName = ($vmHostName.split("."))[0]}
		$netAdapt = $_ | Get-NetworkAdapter | ? {$_.networkname -eq $FromNetwork } ;
		$netName = $netAdapt.networkname
		if ($netName -eq $null ) {$netName = "VM Guest NOT on port group"} ;
		$OnOff = $_.PowerState ;
		$pingstatus = " "
		if ($OnOff -eq "PoweredOn")
			{if (IsPingable($vmHostName))
			  {$pingstatus = "Pingable"}
			else
			  {$pingstatus = "NOT Pingable"} }
		[string]::join(" ; ",($vmName, $vmHostName, $netName, $OnOff, $pingstatus)) ;
		
###   This is section that does the change    ####
		
		if ( $netName -eq $FromNetwork -and $pingstatus -eq "Pingable")
     		{"Change Me" ; $netAdapt | set-networkadapter -networkname $ToNetwork -confirm:$false; 
			if (IsPingable($vmHostName) ) {"OK"} else {"Change Failed, Exiting" ; exit }}
		else {"Do not change me"} 		
	         }


