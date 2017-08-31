#load vmware environment
. "D:\Program Files\Altiris\eXpress\Deployment Server\lib\AEP\powershell\master.ps1"
add-vmhost $ARGS[0] -user root -password password -location (get-cluster "esx staging")