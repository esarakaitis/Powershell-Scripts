$clusview = get-cluster | get-view
$clusview | %{ 
  foreach($h in $_.Host){ 
      $clusname = $_.name
      $name = get-view $h
      "" | select @{Name="Cluster"; Expression={$clusname}},
                  @{Name="Host"; Expression={$name.name}},
                  @{Name="DRS Enabled"; Expression={$clusview.Configuration.DRSConfig.Enabled}},
                  @{Name="Default Behavior"; Expression={$clusview.Configuration.DRSConfig.DefaultVmBehavior}},
                  @{Name="Vmotion Rate"; Expression={$clusview.Configuration.DRSConfig.VmotionRate}},
                  @{Name="HA Enabled"; Expression={$clusview.Configuration.DasConfig.Enabled}},
                  @{Name="Failover Level"; Expression={$clusview.Configuration.DasConfig.FailoverLevel}},
                  @{Name="AdmissionControlEnabled"; Expression={$clusview.Configuration.DasConfig.AdmissionControlEnabled}},
                  @{Name="Restart Priority"; Expression={$clusview.Configuration.DasConfig.defaultvmsettings.restartpriority}},
                  @{Name="Isolation Response"; Expression={$clusview.Configuration.DasConfig.defaultvmsettings.isolationresponse}}
     } 
  }
