$physnics = get-vmhost | get-vmhostnetwork | % {$_.Physicalnic}

set-vmhostnetworkadapter -PhysicalNic $physnics -BitRatePerSecMB 1000 -Duplex full