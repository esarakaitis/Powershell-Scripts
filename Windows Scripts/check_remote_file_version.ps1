$servers = get-content c:\comp.txt
$items = get-content c:\binarys.txt


foreach ($server in $servers)
    {
        foreach ($item in $items)
            {
                $fileinfo = (Get-ChildItem "\\$server\c$\Program Files\Citrix\Provisioning Services\$item").VersionInfo
                       "" | select @{Name="Hostname"; Expression={$server}},
                @{Name="Filename"; Expression={$item}},
                @{Name="Fileversion"; Expression={$fileinfo.fileversion}}
            }

            
        }
       