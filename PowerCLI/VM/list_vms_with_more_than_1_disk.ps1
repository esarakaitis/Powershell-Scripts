Get-View -ViewType "VirtualMachine" | Where-Object {$_.Config.DatastoreUrl.Count -gt 1} | select Name
