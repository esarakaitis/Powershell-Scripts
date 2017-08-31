foreach ($folder in get-folder)
    { 
    foreach ($vmachine in $folder | get-vm)
        {
    "" | select @{Name = "Folder"; Expression = {$folder.name}}, @{Name = "VM"; Expression = {$vmachine.name}}
        }
    }