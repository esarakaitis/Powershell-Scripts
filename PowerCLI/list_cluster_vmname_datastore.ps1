get-cluster |`
  %{$cluster = $_; get-vm -Location $_ |
    %{$vm = $_; $dsNames = get-datastore -vm $_ | % {$_.name};
      write-host $cluster.name $vm.name $dsNames
    }
  }