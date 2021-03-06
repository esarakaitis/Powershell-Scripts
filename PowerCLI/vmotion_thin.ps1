param($VM)

if ($VM) {$rootsnap = $VM|%{Get-View -ViewType VirtualMachine -Filter @{"Name" = $_}}|%{$_.Snapshot.RootSnapshotList}}
else
{$rootsnap = Get-View -ViewType VirtualMachine |%{$_.Snapshot.RootSnapshotList}}

$snaplist = @()
$snaplist += $rootsnap

function get-snapshotlegacy ($rootsnap){
foreach ($snap in ($rootsnap|%{$_.ChildSnapshotList})){
$snap
if ((($snap|%{$_.ChildSnapshotList})|Measure-Object).count -gt 0){
get-snapshotlegacy $snap
}
}
}

$snaplist += get-snapshotlegacy $rootsnap
$snaplist