$vms = @()
 "Hostname,NumberofPartitions,NumberOfDisks" | out-file c:\output.csv
	get-vm | % {
	$hdcount = ($_ | get-harddisk | measure-object).count
$vmguest = $_.guest.hostname
$strComputer = $vmguest

$colItems = get-wmiobject -class "Win32_DiskDrive" -namespace "root\CIMV2" `
-computername $strComputer

$partnum=0

foreach ($objItem in $colItems) {
	$partnum += $objItem.Partitions
}
"$vmguest,$partnum,$hdcount" | out-file  c:\output.csv -append
}
