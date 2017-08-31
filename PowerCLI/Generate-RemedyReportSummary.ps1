
Function Main
{
	if ($script:args.length -lt 1) {ShowUsage}
	$datafile = $script:args[0]
	$report_data = Import-Csv $datafile -Header Cluster,VM,Environment,DrTier
	
	$cluster_data = @{}
	foreach ($item in $report_data)
	{
		if ($cluster_data.containsKey($item.Cluster))
		{
			if ($cluster_data[$item.Cluster].containsKey($item.Environment))
			{
				if ($cluster_data[$item.Cluster][$item.Environment].containsKey($item.DrTier))
				{
					# The entry already existed to just add one to the count.
					$cluster_data[$item.Cluster][$item.Environment][$item.DrTier] += 1
				}
				else # Add the tier
				{
					$cluster_data[$item.Cluster][$item.Environment][$item.DrTier] = 1
				}
			}
			else # Add environment and tier
			{
				$cluster_data[$item.Cluster][$item.Environment] = @{}
				$cluster_data[$item.Cluster][$item.Environment][$item.DrTier] = 1
			}
		}
		else # Add all of the entries
		{
			$cluster_data[$item.Cluster] = @{}
			$cluster_data[$item.Cluster][$item.Environment] = @{}
			$cluster_data[$item.Cluster][$item.Environment][$item.DrTier] = 1
		}
	}
	
	OutputReport $cluster_data
}

Function OutputReport
{
	param
	(
		$cluster_data = $(throw "Cluster data must be provided to OuputReport")
	)
	
	# cubic, but deals with summarized data so we live with it
	foreach ($cluster in $cluster_data.keys | Sort-Object)
	{
		Write-Host ("{0}" -f $cluster)
		foreach ($environment in $cluster_data[$cluster].keys | Sort-Object)
		{
			Write-Host ("  {0}" -f $environment)
			
			foreach ($dr_tier in $cluster_data[$cluster][$environment].keys | Sort-Object)
			{
				Write-Host ("    {0}`t{1}" -f $dr_tier, $cluster_data[$cluster][$environment][$dr_tier])
			}
		}
	}
}

Function ShowUsage
{
	Write-Host "Generate-RemedyReportSummary.ps1 <Remedy Report csv file>"
	exit 1
}

main
