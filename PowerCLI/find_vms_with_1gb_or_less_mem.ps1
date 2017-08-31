Get-VM | Where `
{ $_.MemoryMB –lt 1024 }