  $hostinfo = get-vmhost ohaephqvm002.aepsc.com
    $vmviews = (Get-View $hostinfo.ID).VM
    $vmviews | % {
    $_ | Get-VIOBjectByVIView
    }
   