$errReport =@()
$rootpswd = "OLDROOTPASS"

$accspec1 = New-Object VMware.Vim.HostPosixAccountSpec
$accspec1.id = "root"
$accspec1.password = "NEWROOTPASS"
$accspec1.shellAccess = "/bin/bash"

Get-VMHost vmesx11srvr.oa.oclc.org | % {
	Connect-VIServer $_.Name -User root -Password $rootpswd -ErrorAction SilentlyContinue -ErrorVariable err
	$errReport += $err
	if($err.Count -eq 0){
	  $si = Get-View ServiceInstance
	  $acctMgr = Get-View -Id $si.content.accountManager 

	  $acctMgr.UpdateUser($accspec1)
	}

	$errReport += $err
	$err = ""
}

$errReport
