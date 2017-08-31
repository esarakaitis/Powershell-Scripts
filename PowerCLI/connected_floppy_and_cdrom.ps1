Write-Output "FloppyDrive Status:"
Get-vm | Select-Object @{ Name="Status"; Expression={(Get-FloppyDrive -VM $_).ConnectionState.Connected}}, @{ Name="Name"; Expression={$_.Name}} | ft
Write-Output "CDDrive Status:"
Get-vm | Select-Object @{ Name="Status"; Expression={(Get-CDDrive -VM $_).ConnectionState.Connected}}, @{ Name="Name"; Expression={$_.Name}} | ft