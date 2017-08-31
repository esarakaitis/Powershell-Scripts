param
(
	[string]$c, # A single computer to check, otherwise get names from
	            # the input stream.
	[int]$days = 7, # Maximum number of days the oldest backup can be.
	[switch]$debug # Optionally show debug messages
)

BEGIN
{
function validateFullBackup($computername)
{
	if ($debug) 
	{
		Write-Host "Validating $computername was backed up in the last $days days."
	}
	
	$cutoffdate = [DateTime]::Now.AddDays(-$days)
	$budate = getMostRecentVmdkBackupDate $computername
	$budate = [DateTime]::Parse($budate)
	if ($debug)
	{
		Write-Host "BU: $budate : Cutoff: $cutoffdate"
	}
		
	if ($budate.CompareTo($cutoffdate) -ge 0)
	{
		$valid = $TRUE
	}
	else
	{
		$valid = $FALSE
	}
	
	"$computername,$budate,$cutoffdate,$valid"
}

function getMostRecentVmdkBackupDate($computername)
{
	$tsmdir = "C:\tsm\baclient"
	$tsmexe = "$tsmdir\dsmc.exe"
	$tsmargs = "query backup -optfile=F:\Backups\$computername\$computername.opt \\$buhost\f$\Backups\$computername.aepsc.com-fullVM\*.vmdk"

	if ($debug)
	{
		Write-Host "Going to execute: $tsmexe"
        Write-Host "With Arguments: $tsmargs"
	}
    
	$ps = New-Object System.Diagnostics.ProcessStartInfo
	$ps.FileName = $tsmexe
	$ps.WorkingDirectory = $tsmdir
	$ps.Arguments = $tsmargs
	$ps.UseShellExecute = $FALSE
	$ps.RedirectStandardOutput = $TRUE
	
	$p = [System.Diagnostics.Process]::Start($ps)
    $output = $p.StandardOutput.ReadToEnd().Split("`r")
	$p.WaitForExit()
	
	# Start off with an old date sentinel
	$recent = New-Object DateTime(1900,1,1)
    
	if ($debug)
	{
		Write-Host "OUTPUT of $tsmexe $tsmargs:"
		Write-Host $output
	}
	$output | Select-String '\d+.*\s+\w\s+\d\d\/\d\d\/\d\d\d\d.*\w+.*' | ForEach-Object {	
		if ($debug)
		{
			Write-Host "OUTPUT of $tsmexe $tsmargs:$_"
		}
		
		$budate = [DateTime][regex]::Match($_.ToString(), '\d\d\/\d\d\/\d\d\d\d \d\d\:\d\d\:\d\d').Value
	
		if ($debug)
		{
			Write-Host "Found backup: $budate"
		}
		if ($budate.CompareTo($recent) -gt 0)
		{
			$recent = $budate
		}
	}
	
	$recent
}

$buhost = [System.Net.Dns]::GetHostName()

# A hostname was specified on the command line.  Process it and exit.
if ($c -ne "")
{
	validateFullBackup $c
	exit
}
} #End of BEGIN

# Process all input objects
PROCESS
{
	if ($debug)
	{
		Write-Host "Processing names from piped input."
	}
	
	validateFullBackup $_

} #End of PROCESS

END
{
	if ($debug)
	{
		Write-Host "Script Complete."
	}
}
