get-vmhost | get-vmhostnetwork | `
foreach-Object {$_.PhysicalNic | Select-Object DeviceName, MAC}