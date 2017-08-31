param(
	[string]$dbuser = $(throw "Must specify a database username: -dbuser <username>"),
	[string]$dbpass = $(throw "Must specify a database password: -dbpass <password>"),
	[string]$vc = "virtualcenter2"
)

# Load needed assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName(”System.Data.OracleClient”)


# The primary entry point into the script
function main()
{
	#Connect to the Virtual Center Server
	[void](Connect-VIServer $vc)
	#TODO Validate that this connection worked
	
    $vmlist = getVmList
    
	[void](validateRemedy $vmlist)
    	
    # Save the data
	$vmlist
}

# Get the list of VMs from Virtual Center
function getVmList()
{
    $data = @()
    
    Get-Cluster | ForEach-Object {
        $cluster=$_
        $vms = $_ | Get-VM | `
            Select-Object @{Name="Cluster"; Expression={$cluster.name}}, @{Name="VMName"; Expression={$_.Name}}, @{Name="Status"; Expression={"Not checked"}}
            $data += $vms
    }
    
    $data
}

# Check the VM data in Remedy.  Returns the vmlist with the status set.
function validateRemedy($vmlist)
{

	$connStr = “Data Source=AMDP;User Id=$dbuser;Password=$dbpass;Integrated Security=no”

	$conn = New-Object System.Data.OracleClient.OracleConnection($connStr)
		
	$command = New-Object System.Data.OracleClient.OracleCommand
	$command.Connection = $conn
	
	$conn.Open()
	
	$vmlist | ForEach-Object {
        $query = "SELECT serial_number, model_name FROM AMD.SERVER_VIEW WHERE type='server' and name='" + $_.VMName + "'"
		$command.CommandText = $query
		
		$data = $command.ExecuteReader()
		
		# If nothing was returned we could not find the asset
		if (!$data.HasRows)
		{
			$_.status = "Not found in Remedy"
		}
		else
		{
			$rowcount = 0
			while ($data.Read())
			{
				$rowcount += 1
				$values = @("","")
				$data.GetValues($values)
				$serial = $values[0]
				$model_name = $values[1]
			}
		
			# Validate the returned data
			$messages = @()
			if ($rowcount -gt 1)
			{
				$messages += "Multiple matches in Remedy"
			}
			else
			{
				if ($serial -ne "vmware")
				{
					$messages += "Serial number is not vmware"
				}
				
				if ($model_name -ne "vmware")
				{
					$messages += "Model name is incorrect"
				}
			}
			
			if ($messages.Count -gt 0)
			{
				$_.Status = [String]::Join(";", $messages)
			}
			else
			{
				$_.status = "Ok"
			}
			
		$data.Close()
		}
    }
	
	$conn.Close()
}

# Start the script
main