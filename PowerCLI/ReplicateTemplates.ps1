# Powershell template replication script

Param
(
	[String]$config_file = $null, # XML configuration file
	[switch]$delete_template #Automatically remove destination template?
)

# Includes
. .\VITkFunctions.ps1


# TODO - determine if a template has been modified and replicate only the ones
#		 that have.
# TODO - validate free space before doing the template clone
# TODO - email on error.  Clone failures.
# TODO - XML schema validation of the configuration file prior to processing it
#        - the xsd has been created, but validation is tricky without the community extensions

# TODO - Document the special procedures required if the template destinations are moved
#		 to a different cluster.

Function main
{
	if (-not $config_file) {show_usage}
	$config_data = [Xml](Get-Content $config_file)
	foreach ($template in $config_data.configuration.template)
	{
        $template_name = $template.name
		Write-Host "Working on template $template_name."
        $src_dc = $template.source_datacenter
		foreach ($destination in $template.destination)
		{
			$dst_dc = $destination.datacenter
			$dst_def_cluster = $destination.default_cluster	
		    Write-Host "Working on destination DC: $dst_dc"
        				
			$dst_datastore = $null
			$dst_host = $null
            
            if (Get-Datacenter $dst_dc | Get-VM $template_name -ErrorAction SilentlyContinue)
            {
                Write-Host "Name conflict: $template_name exists as a VM.  Skipping." -ForegroundColor Red
                continue
            }
            
            Write-Host "Checking if the template already exists."
			$dst_tmpl = Get-Datacenter $dst_dc | Get-Template $template_name -ErrorAction SilentlyContinue
            
            if ($dst_tmpl -and (!$delete_template))
            {
                Write-Host "The template already exists and no deletions are allowed.  Skipping."
                continue
            }
            
			# If the template already exists save information about it
			if ($dst_tmpl)
			{
                Write-Host "$dst_tmpl already exists.  Using existing template information for clone." -ForegroundColor Red
				$template_view = Get-View $dst_tmpl.ID
				$dst_host =  (Get-View $template_view.Runtime.Host).Name
                
                # Assumes only one datastore
				$dst_datastore = $template_view.Config.DatastoreUrl[0].Name
				
                $template_view = $null
				
                # TODO: This is what we need to make sure this is safe enough to avoid a rm -rf * issue
				if ($delete_template)
				{
                    Write-Host "Going to delete the template $dst_tmpl from $dst_dc."
                    if ($dst_tmpl.GetType().Name -eq "TemplateImpl")
                    {
                        # Will set $confirm:$false when testing and review is complete.
                        $dst_tmpl | Remove-Template -DeleteFromDisk                        
                    }
                    else
                    {
                       Write-Host ("Tried to delete a template, but got the following type: {0}" -f $dst_tmpl.GetType().Name)
                       Exit
                    }
				}
			}
			# Otherwise use defaults and some logic to get the information
			else
			{
				$dst_cluster = $dst_def_cluster
                # Get the first host in the cluster
                # TODO: Test that the host is not in maintenance mode, get another one if so
				$dst_host = (Get-Cluster $dst_cluster | Get-VMHost)[0]
				$dst_datastore = find_best_datastore $dst_host
			}
			
			# We have all of the information so go ahead and clone it.
            Write-Host "Starting the clone using the following command: clone_template $src_dc $dst_dc $template_name $dst_datastore $dst_host"
			clone_template $src_dc $dst_dc $template_name $dst_datastore $dst_host
		}
	}
}



Function show_usage
{
	Write-Host ("{0} <config_file> [-delete_template]" -f $MyInvocation.ScriptName)
    Exit
}

# Best is defined as nonreplicated and with the most free space
Function find_best_datastore
{
	Param 
	(
		[VMware.VimAutomation.Client20.VMHostImpl]$vmhost = $(throw "A vmhost must be provided to find_datastore")
	)
	
	$ds = $vmhost | Get-Datastore | `
		Where-Object {$_.Name -like "*_nonrep_*"} | `
		Sort -Property FreeSpaceMB -Descending | Select-Object -First 1
	$ds.name
}

# Start the show
main