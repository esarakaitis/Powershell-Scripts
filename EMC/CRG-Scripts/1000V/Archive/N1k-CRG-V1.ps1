
param
(
   [parameter(Mandatory = $true)]
   [string]
   $DevIPA,
   $DevIPB,
   [switch]
   $nossl,
   [switch]
   $noexcel,
   [switch]
   $Write,
   [switch]
   $Readin
)
Function Format-Data ()
{
Param ($ws,$row,$col,$data)
$startcol = $col
foreach ($item in $data)
{
    $ws.Cells.Item($row, $col) = $item
    $col ++
}

$row = $row +1
$endcol = $col
$col = $startcol
$row,$col,$endcol
}
Function drawHeader
{
   param($sheet, $colHeaders, $SectionTitle, $row, $col)

   ### Section Title
#   $sheet.Cells.Item($startrow,$startcol) = $SectionTitle

   $sheet.Cells.Item($row,$col) = $SectionTitle
   $offset = $colHeaders.length-1
   $newcol = $col+$offset
   $range  = $sheet.Range($sheet.Cells.Item($row, $col), $sheet.Cells.Item($row,$newcol))
   $range.Merge($true)
   $range.Interior.Color      = $dkBlue
   $range.HorizontalAlignment = 3
   $range.Font.Bold           = $true
   $range.Font.Name           = "Arial"
   $range.Font.Size           = 12

   ### Headers
   $row += 1
   $c = $col
   foreach($title in $colHeaders)
   {
      $sheet.Cells.Item($row, $c) = $title
      $c += 1
   }
   $range = $sheet.Range($sheet.Cells.Item($row, $col), $sheet.Cells.Item($row,$newcol))
   $range.Interior.Color = $ltBlue
   $range.Font.Bold      = $true
   $range.Font.Name      = "Arial"
   $range.Font.Size      = 10

   $row, $col, $newcol, $range, $offset
}
#
################################################################################
#
Function drawBox
{
   param($sheet, $range, $startrow, $startcol, $newcol, $offset, $row, $col)

   $range.EntireColumn.AutoFit() | Out-Null
   $range = $sheet.Range($sheet.Cells.Item($startrow, $startcol), $sheet.Cells.Item($row,$newcol))
   

   foreach($edge in $xlGrid)
   {
      $range.Borders.Item($edge).LineStyle  = $xlContinuous
      $range.Borders.Item($edge).Weight     = $xlThin
      $range.Borders.Item($edge).ColorIndex = 1
   }

   $newcol = $startcol+$offset
   $range  = $sheet.Range($sheet.Cells.Item($startrow, $startcol), $sheet.Cells.Item($startrow,$newcol))
   foreach($edge in $xlGrid)
   {
      $range.Borders.Item($edge).LineStyle  = $xlContinuous
      $range.Borders.Item($edge).Weight     = $xlThick
      $range.Borders.Item($edge).ColorIndex = 1
   }

}
#
################################################################################
#

function getN1KInfo ( $Uname , $Pword , $DevIP ) {

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
     $XMLSend | Add-Member NoteProperty DataName "mac_table"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><mac><address-table></address-table></mac></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_mac_addr_tbl___readonly__"
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
          
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "show_cdp"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><cdp><neighbor></neighbor></cdp></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_cdp_neighbors___readonly__ "
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

Write-Host "Pulling Nexus data ."
$NXData = ( type $NXCMDS | plink -ssh -2 -s -l $Uname -pw $Pword $DevIP xmlagent  )

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
#$outfilename = $DevIP + ".xml"
#$EthAggArray | Out-File -Encoding ASCII $outfilename
$XMLArray = [xml]$EthAggArray
#$XMLArray | Out-File -Encoding ASCII BOB7.xml
Write-Host "."
$DevName =$XMLArray.root.show_ver.host_name
Write-Host "done gathering data for $DevIP with hostname $DevName"
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
      "Virtual Center Connection Name`n Data Center-name",
      "Virtual Center IP",
      "Max DvS ports",
      "vCtr Connection Status",
      "vCtr Sync Status",
      "vCtr Version")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v vCenter SVS Connection Information" $row $col
 ### Details/Data
   $row += 1 

   $sheet.Cells.Item($row, $startcol)    = $A.root.show_ver.host_name
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
      "system vlans",
      "vm-max ports",
      "switchport config")
      #"Interface Use")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus 1000v Port Profile Information" $row $col
   ### Details/Data
   $row += 1       
   foreach ($w in $port_profile ) 
        {
   #        Write-Host "." -NoNewline
        $sheet.Cells.Item($row, $startcol)    = $w.ptype
        $sheet.Cells.Item($row, $startcol+1)  = $w.name + "/" + $w.portgrp
        $sheet.Cells.Item($row, $startcol+2)  = $w.sysvl
        $sheet.Cells.Item($row, $startcol+3)  = $w.maxprt
        $sheet.Cells.Item($row, $startcol+4)  = $w.procfg 
        #$sheet.Cells.Item($row, $startcol+5)  = $w.desc 
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
#
# Borders
#
Set-Variable xlEdgeTop          8  -option constant
Set-Variable xlEdgeBottom       9  -option constant
Set-Variable xlEdgeRight        10 -option constant
Set-Variable xlEdgeLeft         7  -option constant
Set-Variable xlInsideHorizontal 12  -option constant
Set-Variable xlInsideVertical   11  -option constant
#
################################################################################
#
# Line Style
#
Set-Variable xlContinuous     1     -option constant
Set-Variable xlDash           -4115 -option constant
Set-Variable xlDot            -4118 -option constant
Set-Variable xlLineStyyleNone -4142 -option constant
#
################################################################################
#
# Line Weight
#
Set-Variable xlHairline 1     -option constant
Set-Variable xlMedium   -4138 -option constant
Set-Variable xlThick    4     -option constant
Set-Variable xlThin     2     -option constant
#
################################################################################
#
# VCE Colors
#
$dkBlue  = [long](0+(143*256)+(197*65536))
$ltBlue  = [long](160+(210*256)+(234*65536))
$ltGray  = [long](166+(166*256)+(166*65536))
$Green   = [long](146+(208*256)+(80*65536))
$Red     = 255
#
$Brown1  = [long](221+(217*256)+(196*65536))
$Brown2  = [long](196+(189*256)+(151*65536))
$Brown3  = [long](148+(138*256)+(84*65536))
$Brown4  = [long](255+(192*256)+(0*65536))
#
$Blue1   = [long](197+(217*256)+(241*65536))
$Blue2   = [long](141+(180*256)+(226*65536))
$Blue3   = [long](83+(141*256)+(213*65536))
$Yellow  = [long](255+(255*256)+(0*65536))
#
$Rose1   = [long](242+(220*256)+(219*65536))
$Rose2   = [long](230+(184*256)+(183*65536))
$Rose3   = [long](218+(150*256)+(148*65536))
$Rose4   = [long](150+(54*256)+(52*65536))
#
$Green1  = [long](235+(241*256)+(222*65536))
$Green2  = [long](216+(228*256)+(188*65536))
$Green3  = [long](196+(215*256)+(155*65536))
$Green4  = [long](118+(147*256)+(60*65536))
#
$Purple1 = [long](228+(223*256)+(236*65536))
$Purple2 = [long](204+(192*256)+(218*65536))
$Purple3 = [long](177+(160*256)+(199*65536))
$Purple4 = [long](96+(73*256)+(122*65536))
#
$Aqua1   = [long](183+(222*256)+(232*65536))
$Aqua2   = [long](146+(205*256)+(220*65536))
$Aqua3   = [long](49+(134*256)+(155*65536))
$Purple  = [long](112+(48*256)+(160*65536))
#
$Orange1 = [long](253+(233*256)+(217*65536))
$Orange2 = [long](252+(213*256)+(180*65536))
$Orange3 = [long](250+(191*256)+(143*65536))
$Orange4 = [long](226+(107*256)+(10*65536))

#
################################################################################
#
# STANDARD Colors
#
$COLOR = @($Brown2, $Blue2,  $Rose2, $Green2, $Purple2, $Aqua2,  $Orange2, 
           $Brown3, $Blue3,  $Rose3, $Green3, $Purple3, $Aqua3,  $Orange3, 
           $Brown4, $Yellow, $Rose4, $Green4, $Purple4, $Purple, $Orange4, 
           $Brown1, $Blue1,  $Rose1, $Green1, $Purple1, $Aqua1,  $Orange1,
           $Brown2, $Blue2,  $Rose2, $Green2, $Purple2, $Aqua2,  $Orange2, 
           $Brown3, $Blue3,  $Rose3, $Green3, $Purple3, $Aqua3,  $Orange3, 
           $Brown4, $Yellow, $Rose4, $Green4, $Purple4, $Purple, $Orange4, 
           $Brown1, $Blue1,  $Rose1, $Green1, $Purple1, $Aqua1,  $Orange1) 
#
################################################################################
#
# Standard Borders to Draw
#
$xlOutline = $xlEdgeTop, $xlEdgeBottom, $xlEdgeRight, $xlEdgeLeft
$xlGrid    = $xlEdgeTop, $xlEdgeBottom, $xlEdgeRight, $xlEdgeLeft, $xlInsideHorizontal, $xlInsideVertical
#
################################################################################


### setup some basic variables if need be
###

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
# now go build the data


#if (($DevIPA) -and ($DevIPA -as [ipaddress])){
# dialog to pop up login prompt 
 $DevCred = Get-Credential admin
 $Uname = $DevCred.GetNetworkCredential().Username
 $Pword = $DevCred.GetNetworkCredential().Password
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
if ($Write) { 
#$EthAggAArray.length
$outfilea = $DevAName + ".xml"
 $EthAggAArray | Out-File -Encoding ASCII testout.txt
 $EthAggAArray | Out-File -Encoding ASCII $outfilea
# $EthAggAArray | Export-Clixml .\$outfilea
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
$sheetEthAgg        = $wb.Worksheets.Item(1) 
$sheetEthAgg.Name   = "Nexus 1000v"
$wb.Worksheets("Nexus 1000v").Activate


### start in cell B2
[int]$row = 2
[int]$col = 2
# go and execute the XLS build areas   
  $row, $col = BuildN1kVchInfo   $sheetEthAgg $XMLAArray
 $row, $col = BuildN1kSvsInfo $sheetEthAgg $XMLAArray
 $row, $col = BuildN1kSvsDomain $sheetEthAgg $XMLAArray
 $row, $col = BuildN1kLicense $sheetEthAgg $XMLAArray
 $row, $col = BuildN1kVlanData $sheetEthAgg $XMLAArray
  $row, $col = BuildN1kModuleData $sheetEthAgg $XMLAArray
 $row, $col = BuildN1kPrtPflInfo   $sheetEthAgg $XMLAArray 


#######################################################################################################
# # # # # # # # # # # # # # # # Display Spreadsheet # # # # # # # # # # # # # # # # # # # # # # 


Write-Host "Complete - Displaying Excel Spreadsheet (be sure to save it)"
$excel.visible = $true
Write-Host " "
Write-Host " "

