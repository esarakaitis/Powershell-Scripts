
param
(
   [parameter(Mandatory = $true)]
   [string]
   $DevIPA,
   [parameter(Mandatory = $true)]
   [string]
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

function getN5KInfo ( $Uname , $Pword , $DevIP ) {

#
# base grab of stuff.
#
$mynexusgrab=@()

     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "lldp_nei"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><lldp><neighbor></neighbor></lldp></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_lldp_show_neighbors___readonly__"
     $mynexusgrab += $XMLSend
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
     $XMLSend | Add-Member NoteProperty DataName "stp"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><spanning-tree></spanning-tree></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_stp_vlan___readonly__"
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
     $XMLSend | Add-Member NoteProperty DataName "vpc"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><vpc></vpc></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_vpc_brief___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "vpc_role"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><vpc><role></role></vpc></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_vpc_role___readonly__"
     $mynexusgrab += $XMLSend
     $XMLSend = New-Object object
     $XMLSend | Add-Member NoteProperty DataName "vpc_peer"
     $XMLSend | Add-Member NoteProperty sendcmd "<show><vpc><peer-keepalive></peer-keepalive></vpc></show>"
     $XMLSend | Add-Member NoteProperty filterfor "__XML__OPT_Cmd_show_vpc_peer_keepalive___readonly__"
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

#### Build file to grab the data
#something is not right in this  
$NXCMDS = ".\nxcmds.txt"
$myxmlput = @"
<?xml version="1.0"?>
<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
  <capabilities>
    <capability>urn:ietf:params:xml:ns:netconf:base:1.0</capability>
      </capabilities>
</hello>]]>]]>

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

Remove-Item $NXCMDS
Write-Host $NXData.length
if ( $NXData.length -le 1000 ) 
{ Write-Host "collection failed plink or powershell not right, exit and restart powershell"
break
}
# Clean oup some junk.
$NXData2  = $NXData -replace "]]>]]>" , ""
$NXData3  = $NXData2 -replace "nc:rpc-replly" , "nc_rpc_reply"
$NXData4  = $NXData3 | select -Skip 7 
# build the cleaner data set
$EthAggArray =  @()
$EthAggArray += '<?xml version="1.0" encoding="ISO-8859-1"?>'
$EthAggArray += "<root>"
Write-Host "Parsing and sorting returned data..." -NoNewline
foreach ($grp in $mynexusgrab)
 {
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

function BuildN5kChInfo ($sheet, $A ,$B ) {
 Write-Host "Building Nexus chassis area ..." -NoNewline
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
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet Aggegration Switch Information" $row $col
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
     if ( $R.name -eq "Chassis" )
         { 
         #Write-Host "found the chassis " $R.name $R.productid $R.serialnum
         $sheet.Cells.Item($row, $startcol+2)  = $R.productid 
         $sheet.Cells.Item($row, $startcol+3)  = $R.serialnum 
         }
      }
   $sheet.Cells.Item($row, $startcol+4)  = $Uname
   $sheet.Cells.Item($row, $startcol+5)  = $Pword 
   $sheet.Cells.Item($row, $startcol+6)  = $A.root.show_ver.sys_ver_str
   $sheet.Cells.Item($row, $startcol+7)  = $A.root.show_ver.kickstart_ver_str
   $row += 1
   $sheet.Cells.Item($row, $startcol)    = $B.root.show_ver.host_name
   foreach ( $R in $B.root.int_brief.TABLE_interface.ROW_interface ) 
     { 
     if ( $R.interface -eq "mgmt0" )
         { 
         #Write-Host "found the interface " $R.name $R.ip_addr 
         $sheet.Cells.Item($row, $startcol+1)  = $R.ip_addr 
         }
      }
   foreach ( $R in $B.root.inventory.TABLE_inv.ROW_inv ) 
     { 
     if ( $R.name -eq "Chassis" )
         { 
         #Write-Host "found the chassis " $R.name $R.productid $R.serialnum
         $sheet.Cells.Item($row, $startcol+2)  = $R.productid 
         $sheet.Cells.Item($row, $startcol+3)  = $R.serialnum 
         }
      }
   $sheet.Cells.Item($row, $startcol+4)  = $Uname
   $sheet.Cells.Item($row, $startcol+5)  = $Pword 
   $sheet.Cells.Item($row, $startcol+6)  = $B.root.show_ver.sys_ver_str
   $sheet.Cells.Item($row, $startcol+7)  = $B.root.show_ver.kickstart_ver_str
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
    Write-Host "."
   $row, $col 
}

# folded function into VLANS area. it was more applicable.
function BuildN5kSptInfo ($sheet, $A ,$B ) {
 Write-Host "Building Nexus Spanning Tree  area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Name",
      "VLANS",
      "Priority")
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet Aggegration Switch Information" $row $col
 ### Details/Data
   $row += 1 
  
      foreach ( $sp in $A )
      {
      Write-Host "."  -NoNewline
      Write-Host "STP stuff for" $sp.name $sp.vlans $sp.priority
      $sheet.Cells.Item($row, $startcol)    = $sp.name
      $sheet.Cells.Item($row, $startcol+1)  = $sp.vlans
      $sheet.Cells.Item($row, $startcol+2)  = $sp.priority
      $row += 1
      }
       $row -= 1
    foreach ( $sp in $B )
      {
      Write-Host "."  -NoNewline 
      Write-Host "STP stuff for" $sp.name $sp.vlans $sp.priority
      $sheet.Cells.Item($row, $startcol)    = $sp.name
      $sheet.Cells.Item($row, $startcol+1)  = $sp.vlans
      $sheet.Cells.Item($row, $startcol+2)  = $sp.priority
      $row += 1
      }
    $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
 Write-Host "."
$row, $col 
}

function BuildN5kvPCInfo ($sheet, $A ,$B ) {
 Write-Host "Building Nexus vPC   area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Name",
      "IP",
      "PeerIP",
      "peer-link",
      "VRF/interface",
      "Role",
      "Role Priorty",
      "Sys Priority")
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet vPC Information" $row $col
 ### Details/Data
   $row += 1 
      $sheet.Cells.Item($row, $startcol)    = $A.root.show_ver.host_name
      foreach ( $R in $A.root.int_brief.TABLE_interface.ROW_interface ) 
      { 
          if ( $R.interface -eq $A.root.vpc_peer.'vpc-keepalive-send-interface' )
          { 
          $sheet.Cells.Item($row, $startcol+1)  = $R.ip_addr 
         }
      }
      $sheet.Cells.Item($row, $startcol+2)  = $A.root.vpc_peer.'vpc-keepalive-dest'
      $sheet.Cells.Item($row, $startcol+3)  = $A.root.vpc.TABLE_peerlink.ROW_peerlink.'peerlink-ifindex'
      $sheet.Cells.Item($row, $startcol+4)  = $A.root.vpc_peer.'vpc-keepalive-vrf' + " / " +$A.root.vpc_peer.'vpc-keepalive-send-interface' 
      $sheet.Cells.Item($row, $startcol+5)  = $A.root.vpc_role.'vpc-current-role'
      $sheet.Cells.Item($row, $startcol+6)  = $A.root.vpc_role.'vpc-local-system-prio'
      $sheet.Cells.Item($row, $startcol+7)  = $A.root.vpc_role.'vpc-system-prio'
      $row += 1
      Write-Host "."  -NoNewline 
   $sheet.Cells.Item($row, $startcol)    = $B.root.show_ver.host_name
      foreach ( $R in $B.root.int_brief.TABLE_interface.ROW_interface ) 
      { 
          if ( $R.interface -eq $B.root.vpc_peer.'vpc-keepalive-send-interface' )
          { 
          $sheet.Cells.Item($row, $startcol+1)  = $R.ip_addr 
         }
      }
      $sheet.Cells.Item($row, $startcol+2)  = $B.root.vpc_peer.'vpc-keepalive-dest'
      $sheet.Cells.Item($row, $startcol+3)  = $B.root.vpc.TABLE_peerlink.ROW_peerlink.'peerlink-ifindex'
      $sheet.Cells.Item($row, $startcol+4)  = $B.root.vpc_peer.'vpc-keepalive-vrf' + " / " +$B.root.vpc_peer.'vpc-keepalive-send-interface' 
      $sheet.Cells.Item($row, $startcol+5)  = $B.root.vpc_role.'vpc-current-role'
      $sheet.Cells.Item($row, $startcol+6)  = $B.root.vpc_role.'vpc-local-system-prio'
      $sheet.Cells.Item($row, $startcol+7)  = $B.root.vpc_role.'vpc-system-prio'
     drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
 Write-Host "."
$row, $col 
}

function BuildN5kVLANInfo ($sheet, $A ,$B ) {
 Write-Host "Building Nexus VLAN   area ..." -NoNewline
  # first join the vlan stuff
  
   $VLANS = @()
    foreach ($VL in $A.root.vlans.TABLE_vlanbrief.ROW_vlanbrief ) 
        {
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty id $VL.'vlanshowbr-vlanid'
        $ucs | Add-Member NoteProperty Aside $VL.'vlanshowbr-vlanname'
        foreach ( $SptVL in $A.root.stp.TABLE_tree.ROW_tree ) 
       		{ 
       	 #    Write-Host "here " $VL.'vlanshowbr-vlanid' "were" $SptVL.tree_id
       		if ( $VL.'vlanshowbr-vlanid' -eq $SptVL.tree_id ) 
            {
            $ucs | Add-Member NoteProperty APrio  $SptVL.bridge_priority
            $ucs | Add-Member NoteProperty Aroot  $SptVL.tree_designated_root
            $ucs | Add-Member NoteProperty APcost $SptVL.root_path_cost
            }
          }
          $VLANS += $ucs
        }
        #break
        # finally now add it to the vlans object
        foreach (  $VL in $B.root.vlans.TABLE_vlanbrief.ROW_vlanbrief )
            {
            # Write-Host "outer loop pulled switch b vlan " $VL.'vlanshowbr-vlanid'
            # set test to 0  
            $TESTME = "notyet"  
            #Write-Host "resetting to $TESTME"    
            foreach ( $PVL in $VLANS ) 
            {
            #Write-Host "inner loop just grabbed " $PVL.id "and outter is at " $VL.'vlanshowbr-vlanid'
            if ($VL.'vlanshowbr-vlanid' -eq $PVL.id )
              {# set me to know I found the vlan
               $TESTME = "wasthere"
              #Write-Host "just tested and it " $TESTME
              $PVL | Add-Member NoteProperty Bside $VL.'vlanshowbr-vlanname'
               foreach ( $SptVL in $B.root.stp.TABLE_tree.ROW_tree ) 
       		  { 
       		  #Write-Host "now I am inside looking for SPT stuff to stuff" 
       		  if ( $VL.'vlanshowbr-vlanid' -eq $SptVL.tree_id ) 
               {
             #  Write-Host "found the STP stuff"
               $PVL | Add-Member NoteProperty BPrio  $SptVL.bridge_priority
               $PVL | Add-Member NoteProperty Broot  $SptVL.tree_designated_root
               $PVL | Add-Member NoteProperty BPcost $SptVL.root_path_cost
               break 
              }
              #Write-Host "done with STP loop"
            }
            if ($TESTME -eq "wasthere" ) 
               {
               # Write-Host "Im done with checking it was in there and I added B stuff to it" 
                 break }
             }
             }
            # Write-Host "just finished the inner loop TESTME was set to " $TESTME 
            if ($TESTME -eq "notyet" )
              {
              #Write-Host "*****ok now if you are not there add the data for " $VL.'vlanshowbr-vlanid'
             $ucs = New-Object object
             $ucs | Add-Member NoteProperty id $VL.'vlanshowbr-vlanid'
             $ucs | Add-Member NoteProperty Bside $VL.'vlanshowbr-vlanname'
             foreach ( $SptVL in $B.root.stp.TABLE_tree.ROW_tree ) 
       		 { 
       		  if ( $VL.'vlanshowbr-vlanid' -eq $SptVL.tree_id ) 
              {
              $ucs | Add-Member NoteProperty BPrio  $SptVL.bridge_priority
              $ucs | Add-Member NoteProperty Broot  $SptVL.tree_designated_root
              $ucs | Add-Member NoteProperty BPcost $SptVL.root_path_cost
               
             }  
              }
             $VLANS += $ucs
           }
           
       
      }
    # dummy data
    Write-Host "." -NoNewline
 #       $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "1"
 #       $ucs | Add-Member NoteProperty Aside "default"
 #       $ucs | Add-Member NoteProperty Bside "default"
 #       $ucs | Add-Member NoteProperty APrio "default"
 #       $ucs | Add-Member NoteProperty Aroot "default"
 #       $ucs | Add-Member NoteProperty BPrio "default"
 #       $ucs | Add-Member NoteProperty Broot "default"
 #     $VLANS += $ucs
 #        $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "10"
 #       $ucs | Add-Member NoteProperty Aside "10-both"
 #       $ucs | Add-Member NoteProperty Bside "10-both"
 #       $VLANS += $ucs
 #       $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "100"
 #       $ucs | Add-Member NoteProperty Aside "left"
 #        $VLANS += $ucs
 #       $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "200"
 #       $ucs | Add-Member NoteProperty bside "rIGHT"      
 #       $VLANS += $ucs
 #       $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "133"
 #       $ucs | Add-Member NoteProperty Aside "lEFT"
 #       $ucs | Add-Member NoteProperty Bside "RIGH2"
 #       $VLANS += $ucs
 #         $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "14"
 #       $ucs | Add-Member NoteProperty Aside "lEFT"
 #       $ucs | Add-Member NoteProperty Bside "RIGH2"
 #       $VLANS += $ucs
 #         $ucs = New-Object object
 #       $ucs | Add-Member NoteProperty id "150"
 #       $ucs | Add-Member NoteProperty Aside "GREEN"
 #       $ucs | Add-Member NoteProperty Bside "GREEN"
 #       $VLANS += $ucs
    #}
      $VLANS = $VLANS |Sort-Object @{expression={[double]$_.'id'}}
    # now built the table 
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Vlan ID",
      "Switch A Name",
      "Switch B Name ",
      "Switch A priority",
      "Switch B priority",
      "Switch A root / cost to root",
      "Switch B root / cost to root")
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet  VLAN Information" $row $col
 ### Details/Data
   $row += 1  
     
    foreach ( $sp in $VLANS )
      {
      Write-Host "."  -NoNewline 
   #   Write-Host "VLAN Lists" $sp.id $sp.Aside $sp.Bside
      $sheet.Cells.Item($row, $startcol)    = $sp.id
      
      if ( $sp.Aside -eq $sp.Bside ) {
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+1)  = $sp.Aside
       }
		else {
	  $sheet.Cells.Item($row, $startcol+1)  = $sp.Aside
      $sheet.Cells.Item($row, $startcol+2)  = $sp.Bside
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
      if ( $sp.APrio -eq $sp.BPrio ) {
             $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+3), $sheet.Cells.Item($row,$startcol+4))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+3)  = $sp.APrio}
		else {
      $sheet.Cells.Item($row, $startcol+3)  = $sp.APrio
      $sheet.Cells.Item($row, $startcol+4)  = $sp.BPrio
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+3), $sheet.Cells.Item($row,$startcol+4)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
      
      $sheet.Cells.Item($row, $startcol+5)  = $sp.Aroot + " / " +$sp.APcost
      $sheet.Cells.Item($row, $startcol+6)  = $sp.Broot + " / " +$sp.BPcost
      if ( $sp.Aroot -eq $sp.Broot ) {}
		else {
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+5), $sheet.Cells.Item($row,$startcol+6)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
      
      $row += 1
      }
    $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $range  = $sheet.Range($sheet.Cells.Item($startrow, $startcol), $sheet.Cells.Item($row,$col)) 
    $range.HorizontalAlignment = 3
    $row += 2 
 Write-Host "."
$row, $col 
}

function BuildN5kPcInfo ($sheet, $A ,$B ) {
 Write-Host "Building Nexus Port Channel   area ..." -NoNewline
  # first join the vlan stuff
  
   $PortChannels = @()
   foreach ($loop_1 in $A.root.Port_Channel.TABLE_channel.ROW_channel ) 
        {
        $Y = New-Object object
        $pcnum = $loop_1.group -replace "`n" ,""
        $pcnum = $pcnum -replace " " ,""
        $Y | Add-Member NoteProperty id $pcnum
        $PortChannels += $Y
        }
     foreach ($loop_1 in $B.root.Port_Channel.TABLE_channel.ROW_channel ) 
        {
        $Y = New-Object object
        $pcnum = $loop_1.group -replace "`n" ,""
        $pcnum = $pcnum -replace " " ,""
        $Y | Add-Member NoteProperty id $pcnum
       $PortChannels += $Y
        }
   $PortChannels = $PortChannels | Sort-Object id -Unique |Sort-Object @{expression={[double]$_.'id'}}
   # now add the per side stuff. first add VPC
   foreach ( $currentPc in $PortChannels )
   {
   Write-Host "." -NoNewline
   #Write-Host "walking the list of Port channels, at" $currentPc.id
       foreach ($loop_1 in $A.root.Port_Channel.TABLE_channel.ROW_channel ) 
        {
        $pcnum = $loop_1.group -replace "`n" ,""
        $pcnum = $pcnum -replace " " ,""
        #Write-Host " switch side port channel number is " $pcnum " ok?"
        if ( $currentPc.id -eq $pcnum )
        {
         $vpcPcName = $loop_1.'port-channel' -replace  "port-channel" , "Po"
           $vpcPcName = $vpcPcName -replace "`n" , ""
           $vpcPcName = $vpcPcName -replace " " , ""
           $intfs = "Me"
          # Write-Host "port channel name " $vpcPcName " and " $pcnum " matched. getting members"
           foreach ( $pcmember in $loop_1.TABLE_member.ROW_member )
             { 
              $intfs = $intfs + "," + ( $pcmember.port -replace "Ethernet", "E" )
           #  Write-Host "getting interface" $pcmember.port $intfs
           }
           #Write-Host "all done now clean up the inteface list"
           $intfs =  $intfs -replace "Me,", ""
           $intfs =  $intfs -replace "`n" , ""
           $intfs =  $intfs -replace " " , ""
           #Write-Host "adding interface list" $intfs " to this switch PC:" $currentPc.id
           $currentPc | Add-Member NoteProperty Amembers $intfs 
           foreach ( $loop_3 in $A.root.vpc.TABLE_vpc.ROW_vpc ) 
       	   { 
       	   $vpcifindex = $loop_3.'vpc-ifindex' -replace "`n" , ""
           $vpcifindex = $vpcifindex           -replace " " , ""
          #Write-Host "now looking for vpc details on switch vpc table " $vpcifindex " ok."
       		 if ( $vpcPcName -eq $vpcifindex ) 
             {
             $vpcName = $loop_3.'vpc-id' -replace "`n" , ""
             $vpcName = $vpcName        -replace " " , ""
           #  Write-Host "horray it has a VPC member and it is" $vpcName " ok."
             $currentPc | Add-Member NoteProperty Avpc  $vpcName 
             }
            }
            $vpcPcVlan = $loop_1.'port-channel'
            $vpcPcVlan = $vpcPcVlan -replace "`n" , ""
            $vpcPcVlan = $vpcPcVlan -replace " " , ""
           foreach ( $loop_4 in $A.root.switchport.TABLE_interface.ROW_interface ) 
       		{ 
            $vpcPcVlansw = $loop_4.interface
            $vpcPcVlansw = $vpcPcVlansw -replace "`n" , ""
            $vpcPcVlansw = $vpcPcVlansw -replace " " , ""
            $vpcPcVlanmode = $loop_4.oper_mode
            $vpcPcVlanmode = $vpcPcVlanmode -replace "`n" , ""
            $vpcPcVlanmode = $vpcPcVlanmode -replace " " , ""
       	    #Write-Host " Im on switch port-channel" $vpcPcVlan " interface is " $vpcPcVlansw " ok."
       		
       		if ( $vpcPcVlan -eq $vpcPcVlansw ) 
            {
            #Write-Host "found an interface matching the portchannel name"
            if ( $vpcPcVlanmode -eq "access" ) 
                  { $intfVlan = "Access," + $loop_4.access_vlan }
            else  {   $intfVlan = "Trunk," + $loop_4.trunk_vlans }
            }
            $intfVlan = $intfVlan -replace "`n" ,""
            $intfVlan = $intfVlan -replace " " ,""
            $currentPc | Add-Member NoteProperty Avlan $intfVlan
           }
      # Below one closes out the Switch match with the $portChannels
       }
     # Below one clcoses out the  switch   
     }
  foreach ($loop_1 in $B.root.Port_Channel.TABLE_channel.ROW_channel ) 
        {
        $pcnum = $loop_1.group -replace "`n" ,""
        $pcnum = $pcnum -replace " " ,""
        #Write-Host " switch side port channel number is " $pcnum " ok?"
        if ( $currentPc.id -eq $pcnum )
        {
           $vpcPcName = $loop_1.'port-channel' -replace  "port-channel" , "Po"
           $vpcPcName = $vpcPcName -replace "`n" , ""
           $vpcPcName = $vpcPcName -replace " " , ""
           $intfs = "Me"
          # Write-Host "port channel name " $vpcPcName " and " $pcnum " matched. getting members"
           foreach ( $pcmember in $loop_1.TABLE_member.ROW_member )
             { 
              $intfs = $intfs + "," + ( $pcmember.port -replace "Ethernet", "E" )
           #  Write-Host "getting interface" $pcmember.port $intfs
           }
           #Write-Host "all done now clean up the inteface list"
           $intfs =  $intfs -replace "Me,", ""
           $intfs =  $intfs -replace "`n" , ""
           $intfs =  $intfs -replace " " , ""
           #Write-Host "adding interface list" $intfs " to this switch PC:" $currentPc.id
           $currentPc | Add-Member NoteProperty Bmembers $intfs 
           foreach ( $loop_3 in $B.root.vpc.TABLE_vpc.ROW_vpc ) 
       	   { 
       	   $vpcifindex = $loop_3.'vpc-ifindex' -replace "`n" , ""
           $vpcifindex = $vpcifindex           -replace " " , ""
          #Write-Host "now looking for vpc details on switch vpc table " $vpcifindex " ok."
       		 if ( $vpcPcName -eq $vpcifindex ) 
             {
             $vpcName = $loop_3.'vpc-id' -replace "`n" , ""
             $vpcName = $vpcName        -replace " " , ""
           #  Write-Host "horray it has a VPC member and it is" $vpcName " ok."
             $currentPc | Add-Member NoteProperty Bvpc  $vpcName 
             }
            }
            $vpcPcVlan = $loop_1.'port-channel'
            $vpcPcVlan = $vpcPcVlan -replace "`n" , ""
            $vpcPcVlan = $vpcPcVlan -replace " " , ""
           foreach ( $loop_4 in $B.root.switchport.TABLE_interface.ROW_interface ) 
       		{ 
            $vpcPcVlansw = $loop_4.interface
            $vpcPcVlansw = $vpcPcVlansw -replace "`n" , ""
            $vpcPcVlansw = $vpcPcVlansw -replace " " , ""
            $vpcPcVlanmode = $loop_4.oper_mode
            $vpcPcVlanmode = $vpcPcVlanmode -replace "`n" , ""
            $vpcPcVlanmode = $vpcPcVlanmode -replace " " , ""
       	    #Write-Host " Im on switch port-channel" $vpcPcVlan " interface is " $vpcPcVlansw " ok."
       		
       		if ( $vpcPcVlan -eq $vpcPcVlansw ) 
            {
            #Write-Host "found an interface matching the portchannel name"
            if ( $vpcPcVlanmode -eq "access" ) 
                  { $intfVlan = "Access," + $loop_4.access_vlan }
            else  {   $intfVlan = "Trunk,"+ $loop_4.trunk_vlans }
            }
            $intfVlan = $intfVlan -replace "`n" ,""
            $intfVlan = $intfVlan -replace " " ,""
            $currentPc | Add-Member NoteProperty Bvlan $intfVlan
           }
      # Below one closes out the Switch match with the $portChannels
       }
     # Below one clcoses out the  switch   
     }  
    # below one closes out the $PortChannels
    }
        
    #foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
    # logic 
    # first define the array based upon switch A PC's
    #		 add object for id
    #		 add switch a pc, vpc, vlan, member, purpose
    # Second loop thru B
    #        check for ID existance, if nod add object id
    #		 add switch b pc, vpc, vlan, member, purpose
    Write-Host "!" -NoNewline
   $PortChannels = $PortChannels |Sort-Object @{expression={[double]$_.'id'}}
    # now built the table 
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Port-Channel",
      "vPC ID ",
      "",
      "Member Vlans",
      "",
      "Member Interfaces",
      "",
      "VCE Purpose")
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet PortChannel Switch Information" $row $col
 ### Details/Data
    $range  = $sheet.Range($sheet.Cells.Item($row, $col+1), $sheet.Cells.Item($row,$col+2))
    $range.Merge($true)
    $range.HorizontalAlignment = 3
    $range  = $sheet.Range($sheet.Cells.Item($row, $col+3), $sheet.Cells.Item($row,$col+4))
    $range.Merge($true)
    $range.HorizontalAlignment = 3
    $range  = $sheet.Range($sheet.Cells.Item($row, $col+5), $sheet.Cells.Item($row,$col+6))
    $range.Merge($true)
    $range.HorizontalAlignment = 3
    $range  = $sheet.Range($sheet.Cells.Item($row-1, $col), $sheet.Cells.Item($row,$col+6))
    $range.HorizontalAlignment = 3
 
    $row += 1  
     # darn it I had to build a second row to label the switch.
          $sheet.Cells.Item($row, $startcol)      = ""
          $sheet.Cells.Item($row, $startcol+1)    = "Switch A"
          $sheet.Cells.Item($row, $startcol+2)    = "Switch B"
          $sheet.Cells.Item($row, $startcol+3)    = "Switch A"
          $sheet.Cells.Item($row, $startcol+4)    = "Switch B"
          $sheet.Cells.Item($row, $startcol+5)    = "Switch A"
          $sheet.Cells.Item($row, $startcol+6)    = "Switch B"
          $sheet.Cells.Item($row, $startcol+7)    = ""
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol), $sheet.Cells.Item($row,$startcol+7))
      $range.Interior.Color      = $ltBlue
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      $row += 1
      foreach ( $sp in $PortChannels )
      {
      Write-Host "."  -NoNewline 
      #Write-Host "Port Channel Lists" $sp.id $sp.Avpc $sp.Bvpc $sp.Avlan $sp.Bvlan $sp.Amembers $sp.Bmembers
      $sheet.Cells.Item($row, $startcol)    = $sp.id

       if ( $sp.Avpc -eq $sp.Bvpc ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+1)  = $sp.Avpc
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+1)  = $sp.Avpc
      $sheet.Cells.Item($row, $startcol+2)  = $sp.Bvpc
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
         
      if ( $sp.Avlan -eq $sp.Bvlan ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+3), $sheet.Cells.Item($row,$startcol+4))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+3)  = $sp.Avlan
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+3)  = $sp.Avlan
      $sheet.Cells.Item($row, $startcol+4)  = $sp.Bvlan
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+3), $sheet.Cells.Item($row,$startcol+4)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
      if ( $sp.Amembers -eq $sp.Bmembers ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+5), $sheet.Cells.Item($row,$startcol+6))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+5)  = $sp.Amembers
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+5)  = $sp.Amembers
      $sheet.Cells.Item($row, $startcol+6)  = $sp.Bmembers
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+5), $sheet.Cells.Item($row,$startcol+6)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
  
      switch -CaseSensitive  ( $sp.id )
      {
       "37"
       { $Purpose = "To AMP-SW-A"}      
       "38"
       { $Purpose = "To AMP-SW-B"}       
       "50"
       { $Purpose = "vPC Peer-Link"}      
       "101"
       { $Purpose = "To UCS FI A"}      
       "102"
       { $Purpose = "To UCS FI B"}       
       "201"
       { $Purpose = "To Xblade 2"}      
       "202"
       { $Purpose = "To Xblade 3"}       

        default {$Purpose = "Unknown"} 
       } 
      
      
     $sheet.Cells.Item($row, $startcol+7)  = $Purpose 
      $row += 1
      }
    $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    # also need to add teh abilityt to autosize and line wrap.
    $row += 2 
 Write-Host "."
$row, $col 
}

function BuildN5kEthInfo ($sheet, $A ,$B ) {
 Write-Host "Building Nexus Ether Xconn area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

Write-Host "."
     # Building LLDP  neighbor informatoin
     $LLDP_2 = @()
  foreach ($item in $A.root.lldp_nei.get_InnerXml())
        {
        $item    = $item -replace "Eth" , "Ethernet"
        $item   = ($item -split '<chassis_type>')
        foreach ($myitem in $item)
         {
         Write-Host "." -NoNewline
         $lldpobj = New-Object object
         #Write-Host "inside of chassis type split"
         $left = ($myitem -split '</chassis_type>')[0]
         $right =($myitem -split '</chassis_type>')[1]
         # Write-Host "checking for left" $left
         # Write-Host "check for right " $right 
         $right1 =($right -split '<chassis_id>')[1]
         $lldpobj | Add-Member NoteProperty chassis_id ($right1 -split '</chassis_id>')[0]
         $right2 =($right1 -split '<l_port_id>')[1]
         $lldpobj | Add-Member NoteProperty l_chassis_id "A"
         $lldpobj | Add-Member NoteProperty l_port_id ($right2 -split '</l_port_id>')[0]
         $right3 =($right2 -split '<port_id>')[1]
         #Write-Host "last thing port_id" ($right3 -split '</port_id>')[0]
         $lldpobj | Add-Member NoteProperty port_id ($right3 -split '</port_id>')[0]
         # Write-Host " whole string" $myitem
         $LLDP_2 +=$lldpobj
         }
      }
        #Write-Host "is there anything there" $LLDP
        foreach ($item in $B.root.lldp_nei.get_InnerXml())
        {
        $item    = $item -replace "Eth" , "Ethernet"
        $item   = ($item -split '<chassis_type>')
        foreach ($myitem in $item)
         {
         Write-Host "." -NoNewline
         $lldpobj = New-Object object
         #Write-Host "inside of chassis type split"
         $left = ($myitem -split '</chassis_type>')[0]
         $right =($myitem -split '</chassis_type>')[1]
         # Write-Host "checking for left" $left
         # Write-Host "check for right " $right 
         $right1 =($right -split '<chassis_id>')[1]
         $lldpobj | Add-Member NoteProperty chassis_id ($right1 -split '</chassis_id>')[0]
         $right2 =($right1 -split '<l_port_id>')[1]
         $lldpobj | Add-Member NoteProperty l_chassis_id "B"
         $lldpobj | Add-Member NoteProperty l_port_id ($right2 -split '</l_port_id>')[0]
         $right3 =($right2 -split '<port_id>')[1]
         #Write-Host "last thing port_id" ($right3 -split '</port_id>')[0]
         $lldpobj | Add-Member NoteProperty port_id ($right3 -split '</port_id>')[0]
         # Write-Host " whole string" $myitem
         $LLDP_2 +=$lldpobj
         }
      }
      #### building interface descriptions
    
           $Aint_list =@()
      foreach ( $sp in $A.root.int_descr.TABLE_interface.ROW_interface )    
      {
       Write-Host "." -NoNewline
        if ( $sp.desc )
        { $ME = New-Object object
         #  Write-Host $sp.interface $sp.desc
          $ME | Add-Member NoteProperty interface $sp.interface
          $ME | Add-Member NoteProperty desc $sp.desc
          $Aint_list +=$ME
        }
        }
      $Bint_list =@()
      foreach ( $sp in $B.root.int_descr.TABLE_interface.ROW_interface )
       {
        Write-Host "." -NoNewline
        if ( $sp.desc )
        { $ME = New-Object object
          $ME | Add-Member NoteProperty interface $sp.interface
          $ME | Add-Member NoteProperty desc $sp.desc
          $Bint_list +=$ME
        }
        }
   # foreach ($w in $Bint_list )      { Write-Host $w.interface }  
      # Look up all of the interfaces, it it is up, add the descr 
            #  #2 is it is not, is there a description on it?
      # skip all others.
    
 
    
foreach ( $sp in $A.root.int_brief.TABLE_interface.ROW_interface )
      {
       Write-Host "." -NoNewline
       foreach ($spa in $Aint_list )
            { if ($spa.interface -eq $sp.interface ) 
                {
                $spa | Add-Member NoteProperty portmode $sp.portmode
                $spa | Add-Member NoteProperty vlan $sp.vlan
                }
               elseif ( $sp.state -eq "up" )
                { 
                  # add it # end of int_descr for A
                  $up_descr_empty = New-Object object
                  $up_descr_empty | Add-Member NoteProperty interface $sp.interface
                  $up_descr_empty | Add-Member NoteProperty vlan $sp.vlan
                  $Ainst_list +=$up_descr_empty
                 }
         }
   }
   foreach ($spa in $Aint_list )
       {
        foreach ($x in $LLDP_2 ) 
        {
         if ( $x.l_chassis_id -eq "A" )
           { if ($x.l_port_id -eq $spa.interface )
               {
               $spa | Add-Member NoteProperty chassis_id $x.chassis_id
               $spa | Add-Member NoteProperty port_id $x.port_id  
               }
             }
         }
      } 
         
       Write-Host "done with A "
      # foreach ($w in $Aint_list ) { Write-Host $w.interface }  
        foreach ( $sp in $B.root.int_brief.TABLE_interface.ROW_interface )
      {
       Write-Host "." -NoNewline       
             foreach ($spa in $Bint_list )
            { if ($spa.interface -eq $sp.interface ) 
                {
                $spa | Add-Member NoteProperty portmode $sp.portmode
                $spa | Add-Member NoteProperty vlan $sp.vlan
                }
               elseif ( $sp.state -eq "up" )
                { 
                  # add it # end of int_descr for B
                  $up_descr_empty = New-Object object
                  $up_descr_empty | Add-Member NoteProperty interface $sp.interface
                  $up_descr_empty | Add-Member NoteProperty vlan $sp.vlan
                  $Binst_list +=$up_descr_empty
                 }
             }
        }
        foreach ($spa in $Bint_list )
               {
        Write-Host "." -NoNewline
               foreach ($x in $LLDP_2 ) 
                  {
                  if ( $x.l_chassis_id -eq "B" )
                   { if ($x.l_port_id -eq $spa.interface )
                      {
                      $spa | Add-Member NoteProperty chassis_id $x.chassis_id
                      $spa | Add-Member NoteProperty port_id $x.port_id  
                    }
                   }
               }
         } 
         
     Write-Host  " Done with B"
     
     $colHeaders = @(
      "Port",
      "Remote Device",
      "Remote Port",
      "Mode",
      "Navtive`nVlans",
      "Interface Use")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet Aggegration Switch A Information" $row $col
 ### Details/Data
   $row += 1       
          #Write-Host "Switch A stuff" $sp.port $sp.rmdid $sp.rmport $sp.mode $sp.vlan $sp.portchnl 
          
        foreach ($w in $Aint_list ) 
        {
           Write-Host "." -NoNewline
        $sheet.Cells.Item($row, $startcol)    = $w.interface
        $sheet.Cells.Item($row, $startcol+1)  = $w.chassis_id
        $sheet.Cells.Item($row, $startcol+2)  = $w.port_id
        $sheet.Cells.Item($row, $startcol+3)  = $w.portmode
        $sheet.Cells.Item($row, $startcol+4)  = $w.vlan 
        $sheet.Cells.Item($row, $startcol+5)  = $w.desc 
        $row += 1
        }
      #end of int_brief for A
      
     $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    #$row += 2 
  # Write-Host $row $col 
   $row = $startrow
   $col = $startcol+7
   $startrow = $row
   $startcol = $col
 
    #Write-Host $row $col 
 
    $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Nexus Ethernet Aggegration Switch B Information" $row $col
    ### Details/Data
   $row += 1 

     foreach ($w in $Aint_list ) 
        {
           Write-Host "." -NoNewline
        $sheet.Cells.Item($row, $startcol)    = $w.interface
        $sheet.Cells.Item($row, $startcol+1)  = $w.chassis_id
        $sheet.Cells.Item($row, $startcol+2)  = $w.port_id
        $sheet.Cells.Item($row, $startcol+3)  = $w.portmode
        $sheet.Cells.Item($row, $startcol+4)  = $w.vlan 
        $sheet.Cells.Item($row, $startcol+5)  = $w.desc 
        $row += 1
        }
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
  
if ( Test-Path $DevIPA, $DevIPB )
 {
 Write-Host "Found the files, Now reading."
 Write-Host "reconstituing data"
 $EthAggAArray = [xml] (Get-Content $DevIPA )
 $EthAggBArray = [xml] (Get-Content $DevIPB  )
$testAName =$EthAggAArray.root.show_ver.host_name
$testBName =$EthAggBArray.root.show_ver.host_name
Write-Host "Processing Nexus config files $testAName and $testBName"
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
 $EthAggAArray = getN5KInfo  $Uname $Pword $DevIPA 
 $EthAggBArray = getN5KInfo  $Uname $Pword $DevIPB 
}
### 

# Extract the hostnames
$XMLAArray = [xml]$EthAggAArray
$XMLBArray = [xml]$EthAggBArray
$DevAName =$XMLAArray.root.show_ver.host_name
$DevBName =$XMLBArray.root.show_ver.host_name

################ Save the file 
if ($Write) { 

$outfilea = $DevAName + ".xml"
$outfileB = $DevBName + ".xml"
 $EthAggAArray | Out-File -Encoding ASCII $outfilea
# $EthAggAArray | Export-Clixml .\$outfilea
 $EthAggBArray | Out-File -Encoding ASCII .\$outfileB
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
Write-Host "Creating Compute Information worksheet "
$wb            = $excel.Workbooks.Add()
#
$sheetEthAgg        = $wb.Worksheets.Item(1) 
$sheetEthAgg.Name   = "Aggegrate-Eth"
$wb.Worksheets("Aggegrate-Eth").Activate


### start in cell B2
[int]$row = 2
[int]$col = 2
# go and execute the XLS build areas   
  $row, $col = BuildN5kChInfo   $sheetEthAgg $XMLAArray $XMLBArray
# Combine STP data with VLANS.
#  $row, $col = BuildN5kSptInfo  $sheetEthAgg $EthAggAArray $EthAggBArray
 $row, $col = BuildN5kvPCInfo  $sheetEthAgg $XMLAArray $XMLBArray
  $row, $col = BuildN5kVLANInfo $sheetEthAgg $XMLAArray $XMLBArray
  $row, $col = BuildN5kPcInfo   $sheetEthAgg $XMLAArray $XMLBArray
  $row, $col = BuildN5kEthInfo  $sheetEthAgg $XMLAArray $XMLBArray


#######################################################################################################
# # # # # # # # # # # # # # # # Display Spreadsheet # # # # # # # # # # # # # # # # # # # # # # 


Write-Host "Complete - Displaying Excel Spreadsheet (be sure to save it)"
$excel.visible = $true
Write-Host " "
Write-Host " "

