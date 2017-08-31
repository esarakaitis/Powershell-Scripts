get-vmhost | foreach-object `
{$vmhost=$_
(get-view $_.id).config.storagedevice.scsilun} | `
	select @{name="Hostname"; expression={$vmhost.name}}, canonicalname, model, devicename


#get-vmhost | % {$vmhostname=$_.name; (get-view $_.id).config.storagedevice.scsilun} | select @{name="Hostname"; expression={$vmhostname}}, canonicalname, model, devicename