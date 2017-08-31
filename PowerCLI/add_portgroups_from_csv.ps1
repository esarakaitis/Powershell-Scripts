$esxName = "entprfsc11evdu.esx.oclc.org"
$switchName = "Enterprise Management"
$csvName = "c:\pg.csv" 
$vsw = Get-VMHost -Name $esxName | Get-VirtualSwitch -Name $switchName


Import-Csv $csvName | %{
	$vsw | New-VirtualPortGroup -Name $_.pgName -VLanId $_.vlanId
}
