BEGIN
{
    Function ConvertTo-Template
    {
        param
        (
            $vm
        )
        
        if ($vm)
        {
            $vmview = Get-View $vm.ID
            $vmview.MarkAsTemplate()
        }
    }
    
    foreach ($vm in $args)
    {
        ConvertTo-Template $vm
        
    }
}

PROCESS
{
    ConvertTo-Template $_
}