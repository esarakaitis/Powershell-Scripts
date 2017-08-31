$hostinfo=get-datacenter "CID" | get-vmhost
$hostinfo | % {
    $hostview = get-view $_.id
$hostview1.config.storagedevice.scsilun | % { `
	$lunname=$_.canonicalname
	$vendor=$_.vendor
		"" | select @{name="LunName"; expression={$lunname}}, @{name="Vendor"; expression={$vendor}}
		}
}