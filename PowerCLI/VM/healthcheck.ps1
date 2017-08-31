foreach ($cluster in get-cluster)
{
$guestcount = $cluster | get-vm | measure-object
$hostcount = $cluster | get-vmhost |  measure-object
$view = Get-View $cluster.id
"" | select-object @{Name="Cluster"; Expression={$cluster.name}},
	   @{Name="Hosts"; Expression={$hostcount.count}},
	   @{Name="VM's"; Expression={$guestcount.count}},
	   @{Name="HA Enabled"; Expression={$view.configuration.DasConfig.Enabled}},
	   @{Name="DRS Enabled"; Expression={$view.configuration.DRSConfig.Enabled}},
	   @{Name="Admission Control Enabled"; Expression={$view.configuration.dasconfig.Admissioncontrolenabled}},
	   @{Name="CurrentFailoverCapacity"; Expression={$view.Summary.CurrentFailoverLevel}}, 
	   @{Name="TotalCPU(MHz)"; Expression={$view.Summary.TotalCpu}}, 
	   @{Name="TotalMemory(GB)"; Expression={([double]('{0:#.##}' -f ($view.Summary.TotalMemory / 1GB)))}}
}