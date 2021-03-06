foreach ($vmhost in get-cluster "entill01pvdu cluster" | get-vmhost)
        {
        $switchinfo = get-virtualswitch $vmhost -name "illiad"
        foreach ($vmswitch in $switchinfo) { 
                "" | select-object (
                           @{Name = "Name"; Expression = {$vmhost.name}},
                           @{Name = "Vswitch"; Expression = {$vmswitch.name}},
                           @{Name = "NumPorts"; Expression = {$vmswitch.numports}},
                           @{Name = "NumPortsAvailable"; Expression = {$vmswitch.NumPortsAvailable}}
        )                   
        }
        }