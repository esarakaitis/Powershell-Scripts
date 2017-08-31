$LaunchLine = 'powershell.exe -Version 2 -Command "& {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned}"'

$ComputerList = "PC01", "PC02"
foreach($Computer in $ComputerList)
{
    [String]$wmiPath = "\\{0}\root\cimv2:win32_process" -f $computer

    try
    {
        [wmiclass]$Executor = $wmiPath
        $executor.Create($LaunchLine)
    }
    catch
    {
        continue;
    }
}