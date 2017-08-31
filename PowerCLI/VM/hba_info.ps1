get-vmhost | % `
{$vmhost=$_
(get-view $_.id).config.storagedevice.hostbusadapter | `
	select @{name="Hostname"; expression={$vmhost.name}}, @{name="HBA Name"; expression={$_.device}}, @{name="HBA Model"; expression={$_.model}}}
