Get-VIServer virtualcenter2
get-vm | where { `
$_ | get-cddrive | where { `
$_.connectionstate.connected -eq "true" `
} `
}