$ESXiHosts = import-csv C:\users\user\desktop\ESXiHostsandIQNs.csv

#The name of the initator group you want to create an add the hosts to
$InitatorGroupName = "igrp1.san1.afg1.nor1.ems.encore.tech"

#The path you will get the generated commands from
$OutfilePath = "C:\users\user\desktop\NimbleCommands.txt"

#Single statement for creating the initator group if needed (leaves an obvious
#break in the code being generated from the IQN entries)
#$InitatorGroupCreation = "initiatorgrp --create $InitatorGroupName`r`n"
#$InitatorGroupCreation | Out-file $OutfilePath

#Iterate ESX hosts from CSV file and generate commands for adding IQNs
foreach ($ESXiHost in $ESXiHosts) {

    $Label = $ESXiHost.Name
    $IQN = $ESXiHost.Value
    $Command = "initiatorgrp --add_initiators $InitatorGroupName --label $Label --initiator_name $IQN --ipaddr *"
    $Command | Out-file -Append $OutfilePath
}