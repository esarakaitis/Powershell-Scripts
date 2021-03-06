#
# Example: $logger = StdOutSender syslogserver.local
#          $logger.Send("Apr  1 14:14:41", "myhost", "Logger test message"
#
# Send has the following parameters
#          $timestamp, $hostname, $data, $facility = "user", $severity = "info"
#


Function StdOutSender
{
    $FS = New-Object PSObject   
    $FS | Add-Member -MemberType ScriptMethod -Name Send -Value {
        param
        (
            [String]$timestamp = $(throw "Error StdOutSender:init; Timestamp must be given."),
            [String]$hostname = $(throw "Error StdOutSender:init; Hostname must be given."),
            [String]$data = $(throw "Error StdOutSender:init; Log data must be given.")
        )
        # Get a properly formatted data string
        $message = "{0} {1} {2}" -f $timestamp, $hostname, $data
        
        # Fire away
        Write-Host $message
    }
    
    # Emit the newly built object
    $FS
}