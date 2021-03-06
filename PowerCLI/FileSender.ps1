#
# Example: $logger = FileSender syslogserver.local
#          $logger.Send("Apr  1 14:14:41", "myhost", "Logger test message"
#
# Send has the following parameters
#          $timestamp, $hostname, $data, $facility = "user", $severity = "info"
#

# TODO: This is only a placeholder stub and does not write to files.  it should.

Function FileSender
{
    param
    (
        [String]$dest_file = $(throw "Error FileSender: A destination host must be given.")
    )
    
    $FS = New-Object PSObject
    $FS | Add-Member -MemberType NoteProperty -Name _FileHandle -Value $null
    $FS | Add-Member -MemberType ScriptMethod -Name init -Value {
        param
        (
            [String]$dest_file = $(throw "Error FileSender:init; A destination file must be given.")
        )
        # TODO: File opening code
    }
    
    $FS | Add-Member -MemberType ScriptMethod -Name Send -Value {
        param
        (
            [String]$timestamp = $(throw "Error FileSender:init; Timestamp must be given."),
            [String]$hostname = $(throw "Error FileSender:init; Hostname must be given."),
            [String]$data = $(throw "Error FileSender:init; Log data must be given.")
        )
        # Get a properly formatted data string
        $message = "{0} {1} {2}" -f $timestamp, $hostname, $data
        
        # Fire away
        # $this._FileHandle.Append($message)
    }
    
    $FS.init($dest_file)
    
    # Emit the newly built object
    $FS
}