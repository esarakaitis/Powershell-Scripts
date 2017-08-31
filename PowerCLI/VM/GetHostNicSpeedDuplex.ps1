get-vmhost | get-vmhostnetwork | foreach-Object {$_.PhysicalNic | `
	Select DeviceName, BitRatePerSec, FullDuplex}