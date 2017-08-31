get-vmhost | foreach-object `
{$vmhost=$_
(get-view $_.id).config.network.vswitch | `
	select @{name="Hostname"; expression={$vmhost.name}}, @{name="VSwitch"; expression={$_.name}}, @{name="BeaconStatus"; expression={$_.spec.policy.nicteaming.failurecriteria.checkbeacon}}}