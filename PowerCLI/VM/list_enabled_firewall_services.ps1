get-vmhost | foreach-object `
{$vmhost=$_
(Get-View $_.ID).config.firewall.ruleset} | `
	select @{name="Hostname"; expression={$vmhost.name}}, label, enabled | sort Hostname, label
