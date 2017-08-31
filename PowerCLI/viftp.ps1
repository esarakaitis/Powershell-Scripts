

# Commands supported
# connect
# disconnect
# cd
# get
# ls
# lcd
# put
# pwd

# Tests using the datastore browser
 # mkdir - vim.FileManager.makeDirectory
 # download = haTask--vim.NfcService.fileManagement-490
 # upload file = vim.NfcService.fileManagement-511
 # delete = vim.FileManager.delete-534

function main
{
	Write-Host "Virtual Infrastructure FTP"
	
	$script:viserver = $null
	$script:workpath = datastore_path
	$script:datastores = $null

	ftp_prompt
}

function ftp_prompt
{
	$command = ""
	
	while ($command[0] -ne "quit")
	{
		$prompt_char = ">"
		$command = @(get_command $prompt_char)
		process_command $command
	}
}

function get_command
{
	$commandtext = Read-Host $args[0]
	
	# Remove leading and trailing whitespace
	$commandtext = $commandtext -replace "^\s*", ""
	$commandtext = $commandtext -replace "\s*$", ""
	[RegEx]::Split($commandtext, "\s+")
}

function process_command
{
	$command = $args[0]
	switch ($command[0])
	{
		"connect"		{command_connect $command}
		"disconnect"	{command_disconnect}
		"cd"			{command_cd $command}
		"ls"			{command_ls $command}
		"get"			{command_get $command}
		"put"			{command_put $command}
		"lcd"			{command_lcd $command}
		"pwd"			{command_pwd $command}
		"help"			{command_help $command}
		"quit"			{command_quit}
		""				{} #Ignore empty lines
		default			{command_unrecognized $command}
	}
}

function command_connect
{
	$command = $args[0]
	if ($command.length -lt 2)
	{
		Write-Host "You must specify a server name to connect to"
		return
	}
	$targetserver = $command[1]
	
	Write-Host ("Connecting to {0}." -f $targetserver)
	$script:viserver = Connect-VIServer $targetserver -user root -password OpenSesamead
	
	$script:datastores = Get-Datastore
}

function command_disconnect
{
	Write-Host "Disconnecting."
	[Void](Disconnect-VIServer $script:viserver -Confirm:$false)
}

function command_cd
{
	Write-Host "cd has not been fully implemented."
	$command = $args[0]
	
	# cd by itself takes the user back to the root
	if ($command.length -eq 1)
	{
		$script:workpath.Datastore = $null
		$script:workpath.Path = $null
		return
	}
	else
	{
		if ($script:workpath.Datastore)
		{
			$script:workpath.appendPath($command[1])
		}
		else
		{
			$script:workpath.Datastore = $command[1]
		}
	}
}

function command_ls
{
	Write-Host "ls has not been fully implemented."

	if ($script:workpath.Datastore)
	{
		
	}
	else
	{
		foreach ($ds in $script:datastores)
		{
			Write-Host ("{0}" -f $ds.Name)
		}
	}
}

function datastore_path
{
	$dp = New-Object Object
	$dp | Add-Member -MemberType NoteProperty -Name "PathSep" -Value "/"
	$dp | Add-Member -MemberType NoteProperty -Name "Datastore" -Value $null
	$dp | Add-Member -MemberType NoteProperty -Name "Path" -Value $null
	$dp | Add-Member -MemberType ScriptMethod -Name "appendPath" -Value {
		param([String]$subpath)
		if ($this.path){$this.Path += $this.PathSep}
		$this.Path += $subpath
	}
	$dp | Add-Member -MemberType ScriptMethod -Name "toFtpPath" -Value {
		$path = $this.PathSep
		if ($this.Datastore)
		{
			$path += ("{0}{1}" -f $this.Datastore, $this.PathSep)
			if ($this.Path) {$path += ("{0}{1}" -f $this.Path, $this.PathSep)}
		}
		$path
	}
	$dp | Add-Member -MemberType ScriptMethod -Name "toTkeDatastorePath" -Value {"[{0}] {1}" -f $this.Datastore, $this.Path}
	$dp
}

function command_get
{
	Write-Host "get has not been implemented."
}

function command_put
{
	Write-Host "put has not been implemented."
}

function command_lcd
{
	Write-Host "lcd has not been implemented."
}

function command_pwd
{
	Write-Host $script:workpath.toFtpPath()
}

function command_help
{
	Write-Host "help has not been implemented."
}

function command_quit
{
	# If connected
	command_disconnect
	
	Write-Host "Goodbye."
}

function command_unrecognized
{
	"Command: '{0}' is unrecognized." -f $args[0][0]
}

# Start the show
main
