#Version 1
#Author: Eric Sarakaitis
#Lab Build Script
#
#load vmware environment
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\LoadVM.ps1"
#connect to virtualcenter
connect-viserver -server virtualcenter2 -user rdpdomainjoin -password intelplatform
#
#run scripts


. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\enter-maint-mode.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\configure-firewall.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\configure-speed-duplex.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\virtual-switch-portgroup_vm003.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\enable-beacon-probing.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\enable-mac-balancing.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\set-ntp.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\set-sc-mem.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\enable-start-ntpd.ps1"
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\exit-maint-mode.ps1"