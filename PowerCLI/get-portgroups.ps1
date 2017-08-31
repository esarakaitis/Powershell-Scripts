get-vmhost | foreach-object `
{$vmhost=$_
(get-view $_.id).config.network.portgroup | `
	select @{name="Hostname"; expression={$vmhost.name}}, @{name="PortGroup"; expression={$_.spec.name}}, @{name="BeaconStatus"; expression={$_.spec.policy.nicteaming.failurecriteria.checkbeacon}}}