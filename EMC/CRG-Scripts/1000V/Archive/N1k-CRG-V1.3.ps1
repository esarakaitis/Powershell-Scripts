#
# ver 1.0 9-Feb-2012 auvil. 
#           created first release.
#     1.1 27-Feb-2012 auvil Added default to write a file, also added timestamp to file.
#  NOTE Version is just below the input param box.                               #
#  1.2 Robert Auvil 11-Mar-2012 - refering to crg_globalfunc.ps1, added ver up
#                               - top, added VBID variable, added autosave feature
#                               - reformatted date function for data,cfg files   # 
#                               - removed sheet2 and sheet 3
#  1.3 Robert Auvil Justus, Greis; 19-Mar - removed MAC and CDP data collection. altered userinput method.


param
(
   [parameter(Mandatory = $false)]
   [string]
   $VBID,
   [parameter(Mandatory = $false)]
   [string]
   $DevIPA,
   [parameter(Mandatory = $false)]
   [string]
   $Uname,
   [parameter(Mandatory = $false)]
   [string]
   $Pword,
   [switch]
   $noexcel,
   [switch]
   $noWrite,
   [switch]
   $Readin,
   [switch]
   $Batch

)

$myver="N1k Ver1.3"
$myFileDate    = Get-Date -format yyyyMMdd_HH_mm
. .\crg_globalfunc.ps1


function getN1KInfo ( $Uname , $Pword , $hostIP ) {

#
# base grab of stuff.
#
$mynexusgrab=@()
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "show_ver"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><version></version></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_sysmgr_show_version___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "int_brief"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><interface><brief></brief></interface></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_interface_brief___readonly__"
     $mynexusgrab += $XMLSend 
       $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "int_descr"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><interface><descr></descr></interface></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_interface_description___readonly__"
     $mynexusgrab += $XMLSend 
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "inventory"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><inventory></inventory></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_inventory___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "vlans"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><vlan></vlan></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_vlan___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "lic_usage"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><license><usage></usage></license></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_lic_usage___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "port_profile"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><port-profile></port-profile></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_port_profile___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "port_profile_brief"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><port-profile><brief></brief></port-profile></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_port_profile_brief___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "module"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><module></module></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_module_vem___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "switchport"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><interface><switchport></switchport></interface></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_interface_switchport___readonly__"
     $mynexusgrab += $XMLSend

     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "Port_Channel"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><port-channel><summary></summary></port-channel></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_port_channel_summary___readonly__"
     $mynexusgrab += $XMLSend

     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "svs_conn"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><svs><connection></connection></svs></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_vms_show_svs_connection___readonly__"
     $mynexusgrab += $XMLSend
  
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "svs_nei"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><svs><neighbor></neighbor></svs></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_svs_neighbors___readonly__"
     $mynexusgrab += $XMLSend

     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "svs_domain"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><svs><domain></domain></svs></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_svs_domain___readonly__"
     $mynexusgrab += $XMLSend
          

#### Build file to grab the data
#something is not right in this  
$NXCMDS = ".\n1xcmds.txt"
$myxmlput = @"
<?xml version="1.0"?>
<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <capabilities>
    <capability>urn:ietf:params:xml:ns:netconf:base:1.0</capability>
  </capabilities>
</hello>
]]>]]>

<?xml version="1.0"?>
   <nc:rpc message-id="1" xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0"
     xmlns="http://www.cisco.com/nxos:1.0:sysmgrcli">
<nc:get><nc:filter type="subtree">
"@ 

# write the header of the cmds to the file
  $myxmlput  | Out-File -Encoding ASCII  $NXCMDS 
# now write what we are going to get to the file
foreach ( $c in $mynexusgrab ) 
  { 
  $c.sendcmd | Out-File -append -Encoding ASCII $NXCMDS 
 }
# finally close the file out.
echo "</nc:filter></nc:get></nc:rpc>]]>]]>" | Out-File -Append -Encoding ASCII $NXCMDS

  Write-Host "testing for plink"
  $TEST4PLINK = ( plink.exe )
  if ( $TEST4PLINK.length -lt 20 ) 
  {
  Write-Host "plink.exe not found powershell not right, either add plink to your path or restart powershell"
  exit }
  Write-Host "auto-saving ssl key."
  $SSHAUTOEXCEPT = (echo y`nexit  | plink -ssh -l $Uname -pw $Pword $hostIP exit )  

Write-Host "Pulling Nexus data ."
$NXData = ( type $NXCMDS | plink -ssh -2 -s -l $Uname -pw $Pword $hostIP xmlagent  )

#Remove-Item $NXCMDS
Write-Host $NXData.length
#if ( $NXData.length -le 555 ) 
#{ Write-Host "collection failed plink or powershell not right, exit and restart powershell"
#break
#}
# Clean oup some junk.
$NXData2  = $NXData -replace "]]>]]>" , ""
$NXData3  = $NXData2 -replace "nc:rpc-replly" , "nc_rpc_reply"
#$NXData4  = $NXData3 
$NXData4  = $NXData3 | select -Skip 7 
# build the cleaner data set
$EthAggArray =  @()
$EthAggArray += '<?xml version="1.0" encoding="ISO-8859-1"?>'
$EthAggArray += "<root>"
Write-Host "Parsing and sorting returned data..." -NoNewline
foreach ($grp in $mynexusgrab)
 {
   #Write-host "."
   #Write-Host "parsing out" $grp.DataName "
   Write-Host "." -NoNewline
   $start = "<"  + $grp.filterfor + ">"
   $end   = "</" + $grp.filterfor + ">"
   $Out = $false
   $outfile =  $grp.DataName
   $EthAggArray += "<" + $outfile + ">"
   # Need to make the loop faster, can't figure out why the match is not working
   # if ((Get-Content .\a.out.xml) -join "`n" -match '\$start([\s\S]*)\$end') 
   # { $matches[1] }
   foreach ($Line In $NXData4)
    {
     #Write-Host $Line
     #Write-Host "." -NoNewline
     If ($Line.contains($end)) {$Out = $False}
     If ($Out -eq $True) {
      #  Write-Host "*" -NoNewline
        if ( $Line.contains("<__readonly__>") -or  $Line.contains("</__readonly__>")) {}
        else { $EthAggArray += $Line }
       #$EthAggArray +=$Line
     }
     If ($Line.contains($start)) {$Out = $True}
   }
  $EthAggArray += "</" + $outfile + ">"
}
$EthAggArray += "</root>"
#$outfilename = $hostIP + ".xml"
#$EthAggArray | Out-File -Encoding ASCII $outfilename
$XMLArray = [xml]$EthAggArray
#$XMLArray | Out-File -Encoding ASCII BOB7.xml
Write-Host "."
$DevName =$XMLArray.root.show_ver.host_name
Write-Host "done gathering data for $hostIP with hostname $DevName"
# eventually I will return an XML, issues with saving at the main loop
# return $XMLArray 
return $EthAggArray 
}

function BuildN1kVchInfo ($sheet, $A ) {
 Write-Host "Building N1k chassis area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Name",
      "IP Address",
      "Model",
      "Serial",
      "Username",
      "Password",
      "NXOS System",
      "NXOS Kickstart")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v Switch Supervisor  Information" $row $col
 ### Details/Data
   $row += 1 
   $sheet.Cells.Item($row, $startcol)    = $A.root.show_ver.host_name
   foreach ( $R in $A.root.int_brief.TABLE_interface.ROW_interface ) 
     { 
     if ( $R.interface -eq "mgmt0" )
         { 
         #Write-Host "found the interface " $R.interface $R.ip_addr 
         $sheet.Cells.Item($row, $startcol+1)  = $R.ip_addr 
         }
      }
    foreach ( $R in $A.root.inventory.TABLE_inv.ROW_inv ) 
     { 
     if ( $R.name.contains("Chassis") )
         { 
         #Write-Host "found the chassis " $R.name $R.productid $R.serialnum
         $sheet.Cells.Item($row, $startcol+2)  = $R.productid 
         $sheet.Cells.Item($row, $startcol+3)  = "`'" + $R.serialnum 
         }
      }
   $sheet.Cells.Item($row, $startcol+4)  = $Uname 
   $sheet.Cells.Item($row, $startcol+5)  = $Pword 
   $sheet.Cells.Item($row, $startcol+6)  = $A.root.show_ver.sys_ver_str
   $sheet.Cells.Item($row, $startcol+7)  = $A.root.show_ver.kickstart_ver_str
   
   #
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
    Write-Host "."
   $row, $col 
}

function BuildN1kVlanData ( $sheet, $A ) {
   Write-Host "Building N1k Vlan area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Vlan ID",
      "Vlan Name",
      "Vlan State",
      "Vlan shut state")      
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v VLAN Information" $row $col
   ### Details/Data
   $row += 1

   foreach ($vl in $A.root.vlans.TABLE_vlanbrief.ROW_vlanbrief ) 
    {
     Write-Host "." -NoNewLine 
    #Write-Host "vlan" $vl.id "Name" $vl.name "Fabric member" $vl.SwitchId "Vlan Role" $vl.ifRole 
    $sheet.Cells.Item($row, $startcol)    = $vl.'vlanshowbr-vlanid'
    $sheet.Cells.Item($row, $startcol+1)  = $vl.'vlanshowbr-vlanname'
    $sheet.Cells.Item($row, $startcol+2)  = $vl.'vlanshowbr-vlanstate'
    $sheet.Cells.Item($row, $startcol+3)  = $vl.'vlanshowbr-shutstate'
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
   Write-Host "."
    $row, $col
}

function BuildN1kLicense ( $sheet, $A ) {
   Write-Host "Building N1k License area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "lic_count",
      "Feature type",
      "install_status",
      "status",
      "Expires")      
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v License Information" $row $col
 ### Details/Data
   $row += 1
   
 foreach ($li in $A.root.lic_usage.TABLE_lic_usage.ROW_lic_usage ) 
   {
    Write-Host "." -NoNewLine 
   #Write-Host  $cl.scope $li.feature $li.operState $li.defQuant $li.usedQuant
    $sheet.Cells.Item($row, $startcol)    = $li.lic_count
    $sheet.Cells.Item($row, $startcol+1)  = $li.feature_name
    $sheet.Cells.Item($row, $startcol+2)  = $li.install_status
    $sheet.Cells.Item($row, $startcol+3)  = $li.status
    $sheet.Cells.Item($row, $startcol+4)  = $li.expiry
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
  Write-Host "."
    $row, $col
}

function BuildN1kModuleData ( $sheet, $A ) {
   Write-Host "Building N1k Module area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Module #",
      "Module Type",
      "Status",
      "Ports",
      "Server Name",
      "Server IP",
      "VEM Module Version",
      "ESX Host Version",
      "Server UUID")      
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v Moudule Information" $row $col
   ### Details/Data
   $row += 1

   foreach ($vl in $A.root.module.TABLE_modinfo.ROW_modinfo ) 
    {
     Write-Host "." -NoNewLine 
   # work on test to see if VEM is different then active VSM
    if ( $vl.status -eq "active *" ) 
   {
   foreach ($vem in $A.root.module.TABLE_modver.ROW_modver )
     { if ( $vl.modinf -eq $vem.modver ) { $active_vsm_ver = $vem.sw} }
   }
   # #Write-Host "vlan" $vl.id "Name" $vl.name "Fabric member" $vl.SwitchId "Vlan Role" $vl.ifRole 
    $sheet.Cells.Item($row, $startcol)    = $vl.'modinf'
    $sheet.Cells.Item($row, $startcol+1)  = $vl.'modtype'
    $sheet.Cells.Item($row, $startcol+2)  = $vl.'status'
    $sheet.Cells.Item($row, $startcol+3)  = $vl.'Ports'
    foreach ($vem in $A.root.module.TABLE_modsrvinfo.ROW_modsrvinfo )
      {
      if ( $vl.modinf -gt "2" ) {
       if ( $vl.modinf -eq $vem.modsrv )
       {
       $sheet.Cells.Item($row, $startcol+4)  = $vem.'srvname'
       $sheet.Cells.Item($row, $startcol+5)  = $vem.'srvip'
       $sheet.Cells.Item($row, $startcol+8)  = $vem.'srvuuid'
       }
     }
     }
    foreach ($vem in $A.root.module.TABLE_modver.ROW_modver )
      {
       if ( $vl.modinf -gt "2" ) 
       { if  ($vl.modinf -eq $vem.modver )
       {
       $sheet.Cells.Item($row, $startcol+6)  = $vem.'sw'
        if ( $active_vsm_ver -ne $vem.sw ) 
        { 
      #  Write-Host "im a different code level"
      $mrange  = $sheet.Range($sheet.Cells.Item($row, $startcol+6), $sheet.Cells.Item($row,$startcol+6)) 
      $mrange.Interior.Color      = $Yellow
        
        }
       $sheet.Cells.Item($row, $startcol+7)  = $vem.'hw'
       }
    }
    }
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
   Write-Host "."
    $row, $col
}

function BuildN1kSvsInfo ($sheet, $A ) {
 Write-Host "Building N1k SVS Conn area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col


   $colHeaders = @(
      "DvS Switch Name",
      "Virtual Center Connection Name`nData Center-name",
      "Virtual Center IP",
      "Max DvS ports",
      "vCtr Connection Status",
      "vCtr Sync Status",
      "vCtr Version")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v vCenter SVS Connection Information" $row $col
 ### Details/Data
   $row += 1 

   $sheet.Cells.Item($row, $startcol)      = $A.root.show_ver.host_name
   $sheet.Cells.Item($row, $startcol+1)    = $A.root.svs_conn.'conn-name' + "`n" + $A.root.svs_conn.'datacenter-name'
   $sheet.Cells.Item($row, $startcol+2)    = $A.root.svs_conn.ipaddress 
   $sheet.Cells.Item($row, $startcol+3)    = $A.root.svs_conn.dvs_max_ports
   $sheet.Cells.Item($row, $startcol+4)    = $A.root.svs_conn.'conn-oper-status'
   $sheet.Cells.Item($row, $startcol+5)    = $A.root.svs_conn.'conn-sync-status'
   $sheet.Cells.Item($row, $startcol+6)    = $A.root.svs_conn.'vc-version'

   #
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
    Write-Host "."
   $row, $col 
}

function BuildN1kSvsDomain ($sheet, $A ) {
 Write-Host "Building N1k SVS Domain area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col


   $colHeaders = @(
      "SVS Domain ID",
      "Packet VLAN ID",
      "Control VLAN ID",
      "SVS Mode",
      "Layer 3 Interface",
      "vCtr sync state")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v SVS Domain Information" $row $col
 ### Details/Data
   $row += 1 

   $sheet.Cells.Item($row, $startcol)    = $A.root.svs_domain.'domain-id'
   $sheet.Cells.Item($row, $startcol+1)    = $A.root.svs_domain.packet_vlan
   $sheet.Cells.Item($row, $startcol+2)    = $A.root.svs_domain.control_vlan 
   $sheet.Cells.Item($row, $startcol+3)    = $A.root.svs_domain.svs_mode
   $sheet.Cells.Item($row, $startcol+4)    = $A.root.svs_domain.intf
   $sheet.Cells.Item($row, $startcol+5)    = $A.root.svs_domain.sync_state

   #
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
    Write-Host "."
   $row, $col 
}

function BuildN1kPrtPflInfo ($sheet, $A ,$B ) {
 Write-Host "Building N1k Port-Profile area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col
  $port_profile = @()
  foreach ($item in $A.root.port_profile.get_InnerXml())
        {
        # migght need to change something
        #$item    = $item -replace "Eth" , "Ethernet"
        $item   = ($item -split '<profile_name>')
        foreach ($myitem in $item)
         {
         Write-Host "." -NoNewline
         $port_profile_data = ""
         $port_profile_type = ""
         $port_profile_desc = ""
         $port_profile_maxprt = ""
         $port_profile_minprt = ""
         $port_profile_inherit = ""
         $profile_data = ""
         $profile_data1 = ""
         #Write-Host $myitem.length 
         #if ( !$myitem.contains("<") ) {$foreach.moveNext()}
      
         #-match "\bis\W+(?:\w+\W+){1,6}?Favorite\b"
         #Write-Host "inside of chassis type split"
         #$pp | Add-Member NoteProperty profile_name = ($myitem -split '</profile_name>')[0]
         #$left = ($profile_data -split '</status>')[0]
         $port_profile_name = ($myitem            -split '</profile_name>')[0]
         $profile_data      = ($myitem            -split '</profile_name>')[1]
    
         $port_profile_type = ($profile_data      -split "</type>")[0]
         $port_profile_type = ($port_profile_type -split "<type>")[1]
         $profile_data      = ($profile_data      -split "</type>")[1]
  
         $port_profile_desc = ($profile_data       -split "</desc>")[0]
         $port_profile_desc = ($port_profile_desc  -split "<desc>")[1]
         $profile_data      = ($profile_data       -split "</desc>")[1]
        
         $port_profile_maxprt = ($profile_data        -split "</max_ports>")[0]
         $port_profile_maxprt = ($port_profile_maxprt -split "<max_ports>")[1]
         $profile_data        = ($profile_data        -split "</max_ports>")[1]
         
         $port_profile_minprt = ($profile_data        -split "</min_ports>")[0]
         $port_profile_minprt = ($port_profile_minprt -split "<min_ports>")[1]
         $profile_data        = ($profile_data        -split "</min_ports>")[1]
         
         $port_profile_inherit = ($profile_data         -split "</inherit>")[0]
         $port_profile_inherit = ($port_profile_inherit -split "<inherit>")[1]
         $profile_data         = ($profile_data         -split "</inherit>")[1]
         
         # pull out the profile_cfg,eval_cfg, and intf and parse later
         $profile_datam        = ($profile_data         -split "<portgrp>")[0]
         # end of line after intf
         $profile_data         = ($profile_data         -split "<portgrp>")[1]
    
         $port_profile_portgrp = ($profile_data         -split "</portgrp>")[0]
         $port_profile_portgrp = ($port_profile_portgrp      -split "<portgrp>")[1]
         $profile_data         = ($profile_data         -split "</portgrp>")[1]
  
         $port_profile_sysvl   = ($profile_data         -split "</sys_vlans>")[0]
         $port_profile_sysvl   = ($port_profile_sysvl      -split "<sys_vlans>")[1]
         $profile_data         = ($profile_data         -split "</sys_vlans>")[1]
         # don't care about the rest. if we ever do then just keep expanding
         # attributes to grab are cap_l3,cap_iscsi,pprole,port_binding
  
         $profile_data_procfg  = ($profile_datam         -split "<eval_cfg>")[0]
         $profile_data_promr   = $profile_datam          -replace $profile_data_procfg , ""

         $profile_data_procfg  = $profile_data_procfg   -replace "<profile_cfg>" , ""
         $profile_data_procfg  = $profile_data_procfg   -replace "</profile_cfg>" , "`n"
         # parse for, 
         #  switchport mode get the next string. "trunk or access"
         #  switchport trunk "switchport trunk allowed vlan"
         #  switchport access "switchport access vlan"
         #  "pinning packet-van"
         #  "pinning control-vlan"
         #  "mtu"
         #  "service-policy type qos input"
         #  "pinning id" 
         #  "channel-group auto mode on mac-pinning
         # -match "\bis\W+(?:\w+\W+){1,6}?Favorite\b"
          $testit = ""
          $ppmode = ""
          $ppvlans = ""
          $ppcos = ""
          $ppmtu = ""
          $pppin = ""
          $pppacket = ""
          $ppcontrol =""
          $ppcgmode =""
          $procfgdata =@()
          $procfgdata =  ($profile_data_procfg -split "`n")
          #foreach ( $prodata in $profile_data_procfg)
          
          foreach ( $prodata in $procfgdata)
           { if ($prodata.contains("switchport mode")) { $ppmode = $prodata.split()[2]}
            elseif ($prodata.contains("switchport trunk allowed vlan")) { $ppvlans = $prodata.split()[4]}
            elseif ($prodata.contains("switchport trunk allowed vlan")) { $ppvlans = $prodata.split()[4]}
            elseif ($prodata.contains("switchport access vlan")) { $ppvlans = $prodata.split()[3]}
            elseif ($prodata.contains("service-policy type qos input")) { $ppcos = $prodata.split()[4]}

            #elseif ($prodata.contains("pinning id")) { $pppin = $prodata.split()[2]}      
            #elseif ($prodata.contains("pinning control-vlan")) { $pppacket = $prodata.split()[1,2]}      
            #elseif ($prodata.contains("pinning packet-vlan")) { $ppcontrol = $prodata.split()[1,2]}      


            elseif ($prodata.contains("pinning id")) { $pppin = $prodata -replace "pinning",""}      
            elseif ($prodata.contains("pinning control-vlan")) { $pppacket = $prodata -replace "pinning","" }      
            elseif ($prodata.contains("pinning packet-vlan")) { $ppcontrol = $prodata -replace "pinning","" }      
            elseif ($prodata.contains("mtu")) {  $ppmtu = $prodata -replace "mtu",""}      
            elseif ($prodata.contains("channel-group auto mode on")) { $ppcgmode = $prodata.split()[4]}      
           }
           # now join the pinninb stuff
          #$testit = ( echo $profile_data_procfg | % {$_ -match "\bswitchport\smode\s\W{1}" > $null; $matches[0]}  ) 
         #  Write-host "well " $ppmode "and" $ppvlans "and " $ppcos " and " $ppmtu $pppacket $ppcontrol $ppcgmode $pppin
         $profile_data_evlcfg  = ($profile_data_promr     -split "<intf>")[0]
         $profile_data_intf   = $profile_data_promr   -replace $profile_data_evlcfg , ""
         
         $profile_data_evlcfg  = $profile_data_evlcfg   -replace "<eval_cfg>" , ""
         $profile_data_evlcfg  = $profile_data_evlcfg   -replace "</eval_cfg>" , ""
         # not too sure which to use, i am going to leave eval_cfg alone for now
         
         
         $profile_data_intf  = $profile_data_intf   -replace "<intf>" , ""
         $profile_data_intf  = $profile_data_intf   -replace "</intf>" , " "
         # possably pars out a list of interfaces, let's see      
        
         $pp = New-Object object   
         $pp | Add-Member NoteProperty name     $port_profile_name
         $pp | Add-Member NoteProperty ptype    $port_profile_type 
         $pp | Add-Member NoteProperty desc     $port_profile_desc
         $pp | Add-Member NoteProperty maxprt   $port_profile_maxprt
         $pp | Add-Member NoteProperty minprt   $port_profile_minprt
         $pp | Add-Member NoteProperty inherit  $port_profile_inherit
         $pp | Add-Member NoteProperty porgrp   $port_profile_portgrp
         $pp | Add-Member NoteProperty sysvl    $port_profile_sysvl
         $pp | Add-Member NoteProperty procfg   $profile_data_procfg
         $pp | Add-Member NoteProperty evlcfg   $profile_data_evlcfg
         $pp | Add-Member NoteProperty data_intf  $profile_data_intf
         $pp | Add-Member NoteProperty profile_data  $profile_data
  
    
         $pp | Add-Member NoteProperty ppvlans $ppvlans
         $pp | Add-Member NoteProperty ppcos $ppcos
         $pp | Add-Member NoteProperty ppmtu $ppmtu
         $pp | Add-Member NoteProperty pppin $pppin
         $pp | Add-Member NoteProperty pppacket $pppacket
         $pp | Add-Member NoteProperty ppcontrol $ppcontrol
         $pp | Add-Member NoteProperty ppcgmode $ppcgmode
         $pp | Add-Member NoteProperty pinningin $pinningin
         
        # Write-Host "profile name    " $port_profile_name " and " $pp.name
        # Write-Host "profile type    " $port_profile_type " and " $pp.type
        # Write-Host "profile desc    " $port_profile_desc
        # Write-Host "profile maxprt  " $port_profile_maxprt
        # Write-Host "porfile minprt  " $port_profile_minprt 
        # Write-Host "porfile inherit " $port_profile_inherit
        # Write-Host "porfile prtgrp  " $port_profile_portgrp
        # Write-Host "profile sysvl   " $port_profile_sysvl
        # Write-Host "profile procfg  " $profile_data_procfg
        # Write-Host "profile evlcfg  " $profile_data_evlcfg
        # Write-Host "profile intf    " $profile_data_intf
        # Write-Host "check rest of data " $profile_data 
         $port_profile +=$pp
         }
      }
     
     $colHeaders = @(
      "type",
      "Name / Dvs Name",
      "vlans",
      "system vlans",
      "vm-max ports",
      "pinning",
      "COS / MTU" )
      #"Interface Use")
 #Name	Type	VLANs	System Vlans	Pinning	CoS
  $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v Port Profile Information" $row $col
   ### Details/Data
   $row += 1       
   foreach ($w in $port_profile ) 
        {
   #        Write-Host "." -NoNewline
        $sheet.Cells.Item($row, $startcol)    = $w.ptype
        $sheet.Cells.Item($row, $startcol+1)  = $w.name + "/" + $w.portgrp
        $sheet.Cells.Item($row, $startcol+2)  = $w.ppvlans
        $sheet.Cells.Item($row, $startcol+3)  = $w.sysvl
        $sheet.Cells.Item($row, $startcol+4)  = $w.maxprt
        $sheet.Cells.Item($row, $startcol+5)  = $w.pppacket + "," + $w.ppcontrol + "," + $w.pppin
        $sheet.Cells.Item($row, $startcol+6)  = $w.ppcos + "/" + $w.ppmtu
        #$sheet.Cells.Item($row, $startcol+7)  = $w.ppmtu 
        #$sheet.Cells.Item($row, $startcol+8)  = $w.procfg 
        $row += 1
        }
      #end of int_brief for A
      
     $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
   Write-Host "."
$row, $col 
}


################################################################
#
# Main
#
################################################################################

if ($Batch ) {
 Write-Host "batch mode, ignorning interactive input"}
 else {
  $Uname = "admin"
  $Pword = "V1rtu@1c3!"
  $TYPEA = "Nexus 1000v"

  Write-Host " "
  if (!$VBID ) {
    $VBID = Read-Host "Enter the VBLOCK ID " 
   }
  Write-Host " "
  if (!$DevIPA ) {
    if ($readin ) {
      $DevIPA = Read-Host "Enter the name of $TYPEA stored data file" 
    }
    else {
      $DevIPA = Read-Host "Enter the IP address for $TYPEA" 
    }
   }
  Write-Host " "
  Write-Host "VBLOCK ID is set to: $VBID"
   if ($readin ) {
     Write-Host "Stored data file name is set to: $DevIPA"
     }
     else {
     Write-Host "IP address is set to: $DevIPA"
     Write-Host " "
     Write-Host "Username is set to: $Uname"
     Write-Host "Password is set to: $Pword"
    Write-Host " "
    }
  $vUnameAns = Read-Host "Is this correct ([y]/n)?"
  
  if ($vUnameAns -eq "n") {
  do {
    Write-Host " "
  
    $VBID   = Read-Host "Enter the VBLOCK ID "
   if ($readin ) {
    $DevIPA = Read-Host "Enter the name of $TYPEA stored data file"
    }
    else {
    $DevIPA = Read-Host "Enter the IP Address "
    $Uname  = Read-Host "Enter the Username "
    $Pword  = Read-Host "Enter the Password "
    }
    Write-Host " "
  Write-Host " "
  Write-Host "VBLOCK ID            is set to: $VBID"
   if ($readin ) {
     Write-Host "Stored data file name is set to: $DevIPA"
     }
     else {
     Write-Host "IP address is set to: $DevIPA"
     Write-Host " "
     Write-Host "Username is set to: $Uname"
     Write-Host "Password is set to: $Pword"
    Write-Host " "
    }
    Write-Host " "
    $vUnameAns = Read-Host "Are these settings correct (y/n)?"
    $vUnameAns = $vUnameAns.ToLower()
    }
  until ($vUnameAns -eq "y")
  }
}
# end of asking for input.


if ($Readin) 
{ 
  
if ( Test-Path $DevIPA )
 {
 Write-Host "Found the files, Now reading."
 Write-Host "reconstituing data"
 $EthAggAArray = [xml] (Get-Content $DevIPA )
 $testAName =$EthAggAArray.root.show_ver.host_name
Write-Host "Processing Nexus config file $testAName "
 # set the username and password if this is an offline build, we don't want to know them.
     $Uname = "Offline Build"
     $Pword = "Offline Build"
 } else { 
   Write-Host "file specified not found"
   break }
   }
   else {
# dialog to pop up login prompt 
# $DevCred = Get-Credential admin
# $Uname = $DevCred.GetNetworkCredential().Username
# $Pword = $DevCred.GetNetworkCredential().Password
 #
 if (!$Pword) { 
   Write-Host "No creds. provided please answer the dialog box."
  break
  }
 # grab the data.
 $EthAggAArray = getN1KInfo  $Uname $Pword $DevIPA 
}
### 

# Extract the hostnames
$XMLAArray = [xml]$EthAggAArray
$DevAName =$XMLAArray.root.show_ver.host_name

################ Save the file 
if (!$noWrite) { 
 $outfilea = $VBID + "_" + $DevAName + "_" + $myFileDate + ".data"
 $EthAggAArray | Out-File -Encoding ASCII $outfilea
}



if ($noexcel ) { 
Write-Host "you chose no excel output, now exiting."
break }
Write-Host "Creating Excel COM Object... "
$erroractionpreference = "SilentlyContinue"
$excel         = New-Object -ComObject Excel.Application
$excel.visible = $false
################################ Create Array Details Worksheet ######################################
# Fire off Excel COM object
#

#
# build the Excel CRG output
Write-Host "Creating N1k Information worksheet "
$wb            = $excel.Workbooks.Add()
#
$Nexus_1k        = $wb.Worksheets.Item(1) 
$Nexus_1k.Name   = "Nexus 1000v"
$wb.Worksheets("Nexus 1000v").Activate
$Nexus_1k.Cells.Item(1,1) = $myver

### start in cell B2
[int]$row = 2
[int]$col = 2
 $row, $col = BuildN1kVchInfo    $Nexus_1k $XMLAArray
 $row, $col = BuildN1kSvsInfo    $Nexus_1k $XMLAArray
 $row, $col = BuildN1kSvsDomain  $Nexus_1k $XMLAArray
 $row, $col = BuildN1kLicense    $Nexus_1k $XMLAArray
 $row, $col = BuildN1kVlanData   $Nexus_1k $XMLAArray
 $row, $col = BuildN1kModuleData $Nexus_1k $XMLAArray
 $row, $col = BuildN1kPrtPflInfo $Nexus_1k $XMLAArray 

### remove Sheet 2 and 3

$S2 = $wb.sheets | where {$_.name -eq "Sheet2"} 
$S3 = $wb.sheets | where {$_.name -eq "Sheet3"} 
$S2.delete() 
$S3.delete()
#######################################################################################################
# # # # # # # # # # # # # # # # Display Spreadsheet # # # # # # # # # # # # # # # # # # # # # # 


Write-Host "Complete - Displaying Excel Spreadsheet (be sure to save it)"
$excel.visible = $true
Write-Host " "
Write-Host " "
$myWkBk        = "$VBID`_N1k`_$myFileDate`_CRG.xlsx"
$wb.SaveAs("$pwd`\$myWkBk")
