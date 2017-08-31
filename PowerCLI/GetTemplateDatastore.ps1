$report = @()
get-template | get-view | % {
$VMname = $_.Name
$_.datastore | % {
$row = "" | Select TemplateName, Datastore
$row.TemplateName = $VMname
$row.Datastore = (Get-View -Id $_).Info.Name
$report += $row
}
}
$report