get-vmhost | % {(get-view $_.id).config.option} | more