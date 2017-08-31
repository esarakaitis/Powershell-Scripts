$hostinfo=get-vmhost
$hostview=get-view $hostinfo.id
$hostview.config.storagedevice.scsilun | % { `
	$lunname=$_.canonicalname
	$vendor=$_.vendor
		"" | select @{name="LunName"; expression={$lunname}}, @{name="Vendor"; expression={$vendor}}
		}
