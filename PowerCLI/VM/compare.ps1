#get hosts
$clusterhosts=get-cluster "1rp lab" | get-vmhost

#	capture list from host0
$masterdata=$clusterhosts[0] | get-datastore
$masterlist=@{}
$masterdata | % {`
	$masterlist[$_.Name] = $false
	}

#	compare luns from remaining to host0
$clusterhosts | % { `
	$mastertest = $masterlist
	$_ | get-datastore | % {
#datastore loop
	#	if in result not in master error
		if ($mastertest.containskey($_.name)) {
			#mark datastore as seen
			$mastertest.remove($_.name)
		}
		else {				
			write-host extra datastore $_.name
		}
	}
#end datastore loop			
	#	if in master not in result error
	$mastertest | %  {
	if ($mastertest 
		write-host unknown datastore $_.name
	}

compare result of get-datastore
#	write output for those that are dissimiliar


	