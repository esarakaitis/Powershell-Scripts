Get-VIServer virtualcenter2
get-vm | where { `
$_ | get-floppydrive | where { `
$_.connectionstate.connected -eq "true" `
} `
}