#!! <Author>Eric Wannemacher</Author>
#!! <version>1.0</version>
#!! <description>Dump Logs from Virtual Center and/or hosts.</description>
#!! <license>GNU Public License 2.0</license>

# Warning - this was written as a POC to validate some design ideas.  Error
# checking and additional testing should be implemented before relying on this
# script in a production environment.

Param
(
	[String]$config_file = $null, # XML configuration file
    [Int32]$polling_interval = 10, # Number of seconds between polls.
    [Switch]$runonce # Only gathers logs once rather than looping.
)

# Import sender objects
. .\SyslogSender.ps1
# . .\FileSender.ps1
. .\StdOutSender.ps1

# TODO: Use a secure credential store instead of only trusted credentials.
# TODO: Capture and forward Virtual Center logs.
# TODO: Allow this to work on individual hosts without a VC server.
# TODO: Figure out how to make this multithreaded.
# TODO: Look at keeping a connection open to VC because of the high overhead of doing a connection every time.

Function main
{
    if ($runonce)
    {
        Process-Logs
    }
    else
    {
        while ($true)
        {
            Process-Logs
            Start-Sleep $polling_interval
        }
    }
}

Function Process-Logs
{
    # Load the configuration file
    if (-not $config_file) {Show-Usage}
	$config_data = New-Object System.Xml.XmlDocument
    $config_data.Load($config_file)
	# TODO: Validate the configuration file works with the schema
    
    # Open handles to destinations
    $destinations = Load-Destinations $config_data.configuration.destination
       
    # For Each Virtual Center
    foreach ($vc in $config_data.configuration.virtualcenter)
	{
        Connect-Viserver $vc.name
        
        Write-Host ("Working on VC {0}." -f $vc.name)
        
        # TODO: Work on any VC logs
        #foreach ($log in $vc.logs.log)
        #{
        #    Write-Host ("`tWorking on {0} at line {1}" -f $log.name, $log.lastline)
        #    $lastline = Forward-Log $vc.name $log.name $log.lastline
        #    $log.lastline = $lastline.toString()
        #}
        
        # Act on hosts
        foreach ($vmhost in $vc.vmhost)
        {
            Write-Host ("`tWorking on {0}." -f $vmhost.name)
            
            foreach ($log in $vmhost.log)
            {
                Write-Host ("`t`tWorking on {0} starting at line {1}" -f $log.name, $log.lastline)
                $lastline = Forward-Log $vmhost.name $log.name $log.lastline
                $log.lastline = $lastline.toString()
            }
        }
        
        Disconnect-Viserver -confirm:$false
    }
    
    # Save the updated XML configuration document
    $config_data.Save($config_file)
}

#
# Returns a string that contains the message in a format with a syslog header.
#     The message is not length limited in case it is being used some place
#     besided syslog that does not limit the length of the line.
#
Function Normalize-Message
{
    param
    (
        $logfile = $(throw "parse_date:A logfile type must be specified."),
        $hostname = $(throw "parse_date:A hostname must be specified."),
        $data = $(throw "parse_date:Log data must be provided.")
    )
    
    # Get the date format
    
    switch ($logfile)
    {
        # Some are already in syslog format so send them back out.
        "messages" {$data}
        "vmkernel" {$data}
        
        # Some require a little more work
        "hostd" {Normalize-AgentMessage $hostname $data}
        "vpxa"  {Normalize-AgentMessage $hostname $data}
    }
    # TODO: What to do with entries that don't have dates?
}

#
# Returns a string that contains the message in a format with a syslog header.
#     If there is no date, the current date/time of the system running the
#     log forwarder is used.
#     The message is not length limited in case it is being used some place
#     besided syslog that does not limit the length of the line.
#
Function Normalize-AgentMessage
{
    param
    (
        $hostname,
        $data
    )
    $date_time_re = "\d\d\d\d\-\d\d\-\d\d\s\d\d:\d\d:\d\d\.\d\d\d"
    
    $date_time = [Regex]::Match($data, $date_time_re)
    if ($date_time.Success)
    {
        $date_time = [DateTime]::Parse($date_time.Value)
        $data = [Regex]::Replace($data, $date_time_re, "")
    }
    else
    {
        $date_time = Get-Date
    }
    
    # Format the data
    # This is broken up because the syslog RFC uses a leading space instead of
    #     leading 0 when using a single digit day.
    "{0} {1,2} {2} {3} {4}" -f $date_time.ToString("MMM"), $date_time.Day, $date_time.ToString("HH:mm:ss"), $hostname, $data
}

Function Load-Destinations
{
    param
    (
        [System.Xml.XmlElement]$dest_xml = $(throw "Load-Destinations; missing dest_xml parameter")
    )
    
    $destinations = @()
    
    foreach ($destination in $dest_xml.SelectNodes("*"))
    {
        Write-Host ("Adding destination {0}." -f $destination.Name)
        switch ($destination.Name)
        {
            "syslogudp" { $destinations += SyslogUdpSender $destination.FirstChild.Value }
            #"file"      { $destinations += FileSender $destination.FirstChild.Value }
            "stdout"    { $destinations += StdOutSender $destination.FirstChild.Value }
        }
    }
    
    $destinations
}

#
# Returns the last log line processed
# 
Function Forward-Log
{
    param
    (
        [String]$vmhost = $(throw "Must provide a vmhost to Forward-Log."),
        [String]$logname = $(throw "Must provide a logname to Forward-Log."),
        [Int32]$lastline = $(throw "Must provide a startline to Forward-Log.")
    )

    # Get and forward each entry.
    # Unless this is the first entry skip the first one since it was sent last
    # time.  This is done this way because a startline greater than the 
    # available lines will cause the entire log to be read.
    $logdata = Get-Log $logname $vmhost -StartLineNum $lastline
    
    if ($lastline -eq 1)
    {
        $index = 0
    }
    else
    {
        $index = 1
    }
    
    for (; $index -lt $logdata.Entries.Length; $index++)
    {
        $message = Normalize-Message $logname $vmhost $logdata.Entries[$index]
        $date, $time, $hostname, $message = $message.Split(" ")
        foreach ($destination in $destinations)
        {
            [void]$destination.Send($date + " " + $time, $hostname, $message)
        }
    }
    
    if ($logdata.LastLineNum -eq 0)
    {
        1
    }
    else
    {
        $logdata.LastLineNum
    }
}

Function Show-Usage
{
    Write-Host ("{0} <configuration file>" -f $MyInvocation.ScriptName | Split-Path -Leaf)
    exit
}

main