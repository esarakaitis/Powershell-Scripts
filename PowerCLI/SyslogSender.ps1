#
# Example: $logger = SyslogUdpSender syslogserver.local
#          $logger.Send("Apr  1 14:14:41", "myhost", "Logger test message"
#
# Send has the following parameters
#          $timestamp, $hostname, $data, $facility = "user", $severity = "info"
#


Function SyslogUdpSender
{
    param
    (
        [String]$dest_host = $(throw "Error SyslogUdpSender: A destination host must be given.")
    )
    
    $SUS = New-Object PSObject
    $SUS | Add-Member -MemberType NoteProperty -Name _UdpClient -Value $null
    $SUS | Add-Member -MemberType ScriptMethod -Name init -Value {
        param
        (
            [String]$dest_host = $(throw "Error SyslogUdpSender:init; A destination host must be given."),
            [Int32]$dest_port = 514
        )
        $this._UdpClient = New-Object System.Net.Sockets.UdpClient
        $this._UdpClient.Connect($dest_host, $dest_port)
    }
    
    $SUS | Add-Member -MemberType ScriptMethod -Name Send -Value {
        param
        (
            [String]$timestamp = $(throw "Error SyslogUdpSender:init; Timestamp must be given."),
            [String]$hostname = $(throw "Error SyslogUdpSender:init; Hostname must be given."),
            [String]$data = $(throw "Error SyslogUdpSender:init; Log data must be given."),
            [String]$facility = "user",
            [String]$severity = "info"
        )
        $facility_map = @{  "kern" = 0;
                            "user" = 1;
                            "mail" = 2;
                            "daemon" = 3;
                            "security" = 4;
                            "auth" = 4;
                            "syslog" = 5;
                            "lpr" = 6;
                            "news" = 7;
                            "uucp" = 8;
                            "cron" = 9;
                            "authpriv" = 10;
                            "ftp" = 11;
                            "ntp" = 12;
                            #"logaudit" = 13;
                            #"logalert" = 14;
                            "clock" = 15;
                            "local0" = 16;
                            "local1" = 17;
                            "local2" = 18;
                            "local3" = 19;
                            "local4" = 20;
                            "local5" = 21;
                            "local6" = 21;
                            "local7" = 23;
                        }
    
        $severity_map = @{  "emerg" = 0;
                            "panic" = 0;
                            "alert" = 1;
                            "crit" = 2;
                            "error" = 3;
                            "err" = 3;
                            "warning" = 4;
                            "warn" = 4;
                            "notice" = 5;
                            "info" = 6;
                            "debug" = 7;
                            }

        # Map the text to the decimal value
        if ($facility_map.ContainsKey($facility))
        {
            $facility_num = $facility_map[$facility]
        }
        else
        {
            $facility_num = $facility_map["user"]
        }
        
        if ($severity_map.ContainsKey($severity))
        {
            $severity_num = $severity_map[$severity]
        }
        else
        {
            $severity_num = $severity_map["user"]
        }
        
        # Calculate the PRI code
        $pri = ($facility_num * 8) + $severity_num
        
        # Get a properly formatted, encoded, and length limited data string
        $message = "<{0}>{1} {2} {3}" -f $pri, $timestamp, $hostname, $data
        $enc     = [System.Text.Encoding]::ASCII        $message = $Enc.GetBytes($message)
            
        if ($message.Length -gt 1024)
        {
            $message = $message.SubString(0, 1024)
        }
        
        # Fire away
        $this._UdpClient.Send($message, $message.Length)
    }
    
    $SUS.init($dest_host)
    
    # Emit the newly built object
    $SUS
}