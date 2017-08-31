#Version 1
#Author: Eric Sarakaitis
#Lab Build Script
#
#load vmware environment
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\LoadVM.ps1"
#connect to virtualcenter
connect-viserver -server virtualcenter2 -user rdpdomainjoin -password intelplatform
#