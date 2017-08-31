$vc = Get-VIServer virtualcenter2
Get-VM | Where-Object { `
	($_ | `
	Get-NetworkAdapter).NetworkName -eq `
	"build_subnet"}