#load vmware environment
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\master.ps1"
Get-VMHost $ARGS[0] | Set-VMHost -State Connected