$lunpathinfo = @()

$hostinfo=get-vmhost
$hostview=get-view $hostinfo.id
$hostview.config.storagedevice.multipathinfo.lun | % { `
	$lunname=$_.id
	$lunpolicy=$_.policy.policy
	$_.path | % {
		$pathstate=$_.pathstate
		$lunpathinfo += "" | select @{name="Hostname"; expression={$hostinfo.name}}, @{name="LunName"; expression={$lunname}}, @{name="LunPolicy"; expression={$lunpolicy}}, @{name="PathState"; expression={$pathstate}}
	}
}

$lunpathinfo