$progresspreference = "silentlycontinue";
foreach ($vm in get-vm)
    {
        $vm | get-floppydrive | remove-floppydrive -confirm:$false
    }