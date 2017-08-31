##################################################################################
#                                                                                #
# 
# UCS report tool v1.5.                                                          #
# This script is intended to be used for creating the CRG document to hand over  #
#   to the customer for final documentation. To run this script requires that    #
#   you are able to ping the UCS Fabric UCS Clusters and have Excel installed.   #
#                                                                                #
#  Version Update:                                                               #
#  .5 Robert Auvil 11-Feb-2012 _ Script created                                  #
#  .6 Robert auvil 25-Feb-2012 _ Updated finised data parse, starting excel      #
#  .7 Robert auvil 26-Feb-2012 _ excel part done. ready for beta                 #
#  1.0 Robert Auvil 27-Feb-2012 - Added timestamp to dataout                      #
##################################################################################

param
(
   [parameter(Mandatory = $true)]
   [string]
   $hosta,
   [parameter(Mandatory = $true)]
   [string]
   $hostb,
   [switch]
   $Readin,
   [switch]
   $noWrite,
   [switch]
   $noexcel
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
   $sheet.Cells.Item($startrow,$startcol) = $SectionTitle
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



Function getHostInfo ( $Uname , $Pword , $hostIP ) {
  Write-Host "testing for plink"
  $TEST4PLINK = ( plink.exe )
  if ( $TEST4PLINK.length -lt 20 ) 
  {
  Write-Host "plink.exe not found powershell not right, either add plink to your path or restart powershell"
  exit }
  Write-Host "auto-saving ssl key."
  $SSHAUTOEXCEPT = (echo y`nexit  | plink -ssh -l $Uname -pw $Pword $hostIP exit )  
  Write-Host "Getting $hostIP details.."
   ### build string to send to C3560
   echo "term len 0"                      >mycmds
   echo "show ver"                       >>mycmds
   echo "show spanning-tree root"        >>mycmds
   echo "show vlan "                     >>mycmds
   echo "show ip int brief | e unassign" >>mycmds
   echo "show standby brief"             >>mycmds
   echo "show int description"           >>mycmds
   echo "exit" 							 >>mycmds
   $hostmycmds  = ( type mycmds  | plink -ssh -l $Uname -pw $Pword $hostIP -batch  )
   echo "term len 0"                      >mycmds
   echo "show etherchannel summary "     >>mycmds
   echo "show etherchannel detail "      >>mycmds
   echo "exit" 							 >>mycmds
   $hostmycmds += ( type mycmds | plink -ssh -l $Uname -pw $Pword $hostIP -batch  )
   echo "term len 0"                      >mycmds
   echo "show cdp nei "                  >>mycmds
   echo "show int switchport"            >>mycmds
   echo "exit"                           >>mycmds
   $hostmycmds += ( type mycmds | plink -ssh -l $Uname -pw $Pword $hostIP -batch  )
   echo "term len 0"                      >myrun
   echo "show running"                   >>myrun
   echo "exit"                           >>myrun

 Write-Host " "
  
   #Write-Host "Username" $Uname "password " $Pword "IP "$hostaClusterIP
     #$hostmycmds = ( type mycmds | plink -ssh -l $Uname -pw $Pword $hostIP  )
  
   #$hostmycmds += ( type mycmds2 | plink -ssh -l $Uname -pw $Pword $hostIP -batch  )

   $hostmyrun  = ( type myrun | plink -ssh -l $Uname -pw $Pword $hostIP -batch  )
   
   $hostmycmds = $hostmycmds + "RUNNINGSTART" + $hostmyrun 
   
   return $hostmycmds , $hostmyrun 

}

Function buildHostdata ( $hostcmds , $hostrun , $deviceip ) {
$hostsdata = @()
 $sysinfo =@()
#Write-Host "inside of buildHostdata and the lenght of the string is " $hostcmds.length
#$OSver    = ($hostcmds | select-string "RELEASE" | %{$_ -Split","})[2] 
$OSver    = ($hostcmds | select-string "RELEASE" | %{$_ -replace("Version","")} | %{$_ -Split","})[2] 
$hostname = ($hostcmds | Select-String "uptime" | %{$_ -Split" "})[0]
$model    = ($hostcmds | select-string "Model Number" | %{$_ -Split":"})[1]
$serial   = ($hostcmds | select-string "System serial number" |  %{$_ -Split":"})[1]
 
        $info = New-Object object
        $info | Add-Member NoteProperty OSver $OSver
        $info | Add-Member NoteProperty hostname $hostname
        $info | Add-Member NoteProperty ip $deviceip 
        $info | Add-Member NoteProperty model $model
        $info | Add-Member NoteProperty serial $serial
         $sysinfo =$info
         $STPinfo = @()
 Write-Host "STP" -NoNewline
 foreach ( $line in $hostcmds )
 {
 #Write-Host "Building Spanning Tree" $cmdline
 Write-Host "." -NoNewline
 #Write-Host $cmdline 
   if ( $line.contains("$hostname#") ) 
      { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)   
     { if ( $Line.contains("---------------- -------------------- --------- ----- --- ---  ------------") -or $line.length -lt 5)  {}
      else {
      $info = New-Object object
         $spvlan = [int]($line.substring(0,17)|%{$_ -replace("VLAN","")})
         $spvlpri = ($line.substring(17,21)| %{$_ -Split" "})[0]
         $spvlroot = ($line.substring(17,21)| %{$_ -Split" "})[1]
         $spvlrcost = ($line.substring(39,9)).trimstart()
         #Write-Host $spvlan $spvlpri $spvlroot $spvlrcost
         #build out SPTobjects 
         $info = New-Object object
         $info | Add-Member NoteProperty vlanid $spvlan 
         $info | Add-Member NoteProperty pri $spvlpri 
         $info | Add-Member NoteProperty root $spvlroot 
         $info | Add-Member NoteProperty rcost $spvlrcost
         $STPinfo +=$info  
         }
      } 
        
      if ( $line.contains("Vlan                   Root ID          Cost    Time  Age Dly  Root Port")) {$GOTVLAN=$true}
  }
 #
 $VLANS =@()
 Write-Host "."
Write-Host "VLANS"  -NoNewline
 foreach ( $line in $hostcmds ) 
 {
 #Write-Host "Building VLAN data" $cmdline
 Write-Host "." -NoNewline 
 #Write-Host $cmdline 
   if ( $line.contains("VLAN Type  SAID       MTU   Parent RingNo BridgeNo Stp  BrdgMode Trans1 Trans2") ) 
      { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)   
     { if ( $line.startswith("    ") -or $Line.contains("---- -------------------------------- --------- -------------------------------") -or $line.length -lt 5)  {}
      else {
         $vlanid = ($line.Substring(0,4)).TrimEnd()
         $vlanname = ($line.Substring(5,33)).TrimEnd()
         #Write-Host $vlanid $vlanname
         #build out vlan objects 
          $info = New-Object object
         $info | Add-Member NoteProperty vlanid $vlanid 
         $info | Add-Member NoteProperty vlanname $vlanname 
         $VLANS +=$info  
         }
      } 
      if ( $line.contains("VLAN Name                             Status    Ports")) {$GOTVLAN=$true}
  }
 $Etherchnl = @()
Write-Host "."
Write-Host "Port-Channels" -NoNewline
 foreach ( $line in $hostcmds ) 
 {
 #Write-Host "Building Etherchannel data" $cmdline
 Write-Host "." -NoNewline
 #Write-Host $cmdline 
    if ( $line.contains("$hostname#") )   { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)
       {
         if ($line.contains("------+-------------+-----------+-----------------------------------------------") -or $line.length -lt 5 ) {}
         else {
            if ( !$line.Startswith("                       ")) {
            $pgrpno       = ($line.Substring(0,5)).TrimEnd()
            $pgrpint      = ($line.Substring(7,13)).TrimEnd()
            $pgrpmembers  = ($line.Substring(33,($line.length)-33)).TrimEnd()
             }
             else {$pgrpmembers += ($line.Substring(33,($line.length)-33)).TrimEnd()
                  }  
            #Write-Host $pgrpno $pgrpint $pgrpmembers
            $info = New-Object object
            $info | Add-Member NoteProperty pgrpno $pgrpno
            $info | Add-Member NoteProperty pgrpint $pgrpint
            $info | Add-Member NoteProperty pgrpmembers $pgrpmembers
            $Etherchnl += $info
            }
       }  
      if ( $line.contains("Group  Port-channel  Protocol    Ports")) {$GOTVLAN=$true}
  }

 $hsrp = @()
Write-Host "."
Write-Host "HSRP" -NoNewline
 foreach ( $line in $hostcmds ) 
 {
  #Write-Host "Building HSRP data" $cmdline
 Write-Host "." -NoNewline
 #Write-Host $cmdline 
   if ( $line.contains("$hostname#") ) 
      { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)   
        { 
        $hsrpint   = ($line.substring(0,12)).toupper().replace("VL","VLAN").trimend()
        $hsrpgrp   = $line.substring(12,3).trimend()
        $hsrppri   = $line.substring(17,3).trimend()
        $hsrppr    = $line.substring(21,1).trimend()
        $hsrpstate = $line.substring(22,8).trimend()
        $hsrpip    = $line.substring(59,($line.length)-59).trimend()
        #Write-Host $hsrpint $hsrpgrp $hsrppri $hsrppr $hrspstate $hsrpip
        $info = New-Object object
        $info | Add-Member NoteProperty  int     $hsrpint
        $info | Add-Member NoteProperty  grp     $hsrpgrp
        $info | Add-Member NoteProperty  pri     $hsrppri  
        $info | Add-Member NoteProperty  state   $hsrpstate 
        $info | Add-Member NoteProperty  preempt $hsrppr 
        $info | Add-Member NoteProperty  ip      $hsrpip
        $hsrp +=$info  
        }
         
      if ( $line.contains("Interface   Grp  Pri P State   Active          Standby         Virtual IP")) {$GOTVLAN=$true}
  }
Write-Host "."
Write-Host "L3 intfs" -NoNewline
 $L3info =@() 
 foreach ( $line in $hostcmds ) 
 {
  # write-host "building L3 interface info"
 Write-Host "." -NoNewline
 #Write-Host $cmdline 
   if ( $line.contains("$hostname#") ) 
      { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)   
        { 
        $l3int = ($line.substring(0,23)).toupper().trimend()
        $l3ip  = ($line.substring(23,15)).trimend()
        #Write-Host $l3int $l3ip
        $info = New-Object object
        $info | Add-Member NoteProperty int $l3int 
        $info | Add-Member NoteProperty ip $l3ip 
        $L3info +=$info 
        }
         
      if ( $line.contains("Interface              IP-Address      OK? Method Status                Protocol")) {$GOTVLAN=$true}
  }
 Write-Host "CDP"
 $MYCDP =@()
 foreach ( $line in $hostcmds ) 
 {
  # write-host "building CDP interface info"
 #Write-Host "." -NoNewline
 #Write-Host $cmdline 
   if ( $line.contains("$hostname#") ) 
      { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)   
    { 
      #       Write-Host $line.substring(0,17) "t" $line.substring(18,12) "t2" $line.substring(70,8)
     #Write-Host $line.length
     if ( $line.length -lt "50" ) { $cdpneiname = ($line.Substring(0,17)).TrimEnd() }
         else {
     if ( $line.Startswith("  ")) { $int        = ($line.Substring(17,12)).TrimEnd() 
                                     $cdpFarInt  = ($line.Substring(68,($line.length)-68)).TrimEnd()
            #                         Write-Host $int $cdpneiname $cdpFarInt
                                     $info = New-Object object 
                        		     $int=$int.replace("Ten ","TE")
        							 $int=$int.replace("Gig ","GI")
 							         $int=$int.replace("Vlan","VL")
       								 $int=$int.replace("Port-channel","PO")
     							     $int=$int.replace("FastEthernet", "FA") 
                                     $info |Add-Member NoteProperty int $int
                                     $info |Add-Member NoteProperty neiname $cdpneiname 
                                     $info |Add-Member NoteProperty farint $cdpFarInt 
                                     $MYCDP += $info  
                                    }
                              else { $cdpneiname = ($line.Substring(0,17)).TrimEnd()
                                     $int        = ($line.Substring(17,12)).TrimEnd()
                                     $cdpFarInt  = ($line.Substring(68,($line.length)-68)).TrimEnd()
                                     $info = New-Object object 
              						 $int=$int.replace("Ten ","TE")
        							 $int=$int.replace("Gig ","GI")
 							         $int=$int.replace("Vlan","VL")
       								 $int=$int.replace("Port-channel","PO")
     							     $int=$int.replace("FastEthernet", "FA") 
                                     $info |Add-Member NoteProperty int $int
                                     $info |Add-Member NoteProperty neiname $cdpneiname 
                                     $info |Add-Member NoteProperty farint $cdpFarInt 
                                     $MYCDP += $info 
           #                          Write-Host $int $cdpneiname $cdpFarInt
                                    }
            }
       }
                
      if ( $line.contains("Device ID        Local Intrfce     Holdtme    Capability  Platform  Port ID")) {$GOTVLAN=$true}
  }
 Write-Host "Int/VLANS"
 $MYINT =@()
 foreach ( $line in $hostcmds ) 
 {
  # write-host "building interface info"
 Write-Host "." -NoNewline
 #Write-Host $cmdline 
   if ( $line.contains("$hostname#") ) 
      { $GOTVLAN=$false} 
    if ( $GOTVLAN -eq $true)   
        { 
        $int = ($line.substring(0,30)).toupper().trimend()
        $lntstate  = ($line.substring(31,6)).trimend()
        $lntdescr  = $line.substring(54,($line.length)-54)
        # Write-Host $int $lntstate $lntdescr
        $info = New-Object object 
        $info |Add-Member NoteProperty int $int 
        $info |Add-Member NoteProperty intstate $lntstate  
        $info |Add-Member NoteProperty desfarint $lntdescr  
        $MYINT += $info 
        }
       if ( $line.contains("Interface                      Status         Protocol Description")) {$GOTVLAN=$true}
  }
# go collect interface vlan data and build into an array
$runint =@()
# had to find a way of extracting the show run out out the $hostcmds
$mystartline=0
$mylinenumber=0
foreach ($line in $hostrun) {
if ( $line.contains("RUNNINGSTART")) { $mystartline = $mylinenumber }
$mylinenumber++
 }
#Write-Host "start here" $mystartline
$mylinenumber=0
$flush=$false
$info =@()
$bangs=0
foreach ($line in $hostrun )
   {
   $mylinenumber++
   # first junk the top of the array.
   if ($mylinenumber -lt $mystartline ) {continue} 
   #Write-Host "i am on line:"$line  " and it is this long"$line.length
   if ( $line.startswith("!")) { 
       #Write-Host "testing for the !"
       $GOTVLAN=$false
       $bangs++
       # must do 4 things, 
       #           1 add to the array the interface object
       #           2 don't add it for the ! prior to the interfaces
       #           3 don't add it for the # after the last interface
       #           4 flush the data on the first ! seen after the interface 
       if ( $flush=$false -or $bangs -gt "1" ){} 
       else { $runint +=$info }
       $flush=$false } 
   # need to add to end of false logic to add intf data to array object
    if ( $GOTVLAN -eq $true ){
      #Write-Host "testing for GOTVLAN"
       if ($line.contains("switchport mode trunk") )
           {$info | Add-Member NoteProperty mode "trunk"} 
       if ($line.contains("switchport mode access") )
           {$info | Add-Member NoteProperty mode "access"} 
       if ($line.contains("switchport trunk allowed vlan")) 
        {#switchport trunk allowed vlan 1105,1110-1112
         $info | Add-Member NoteProperty allowedvlan $line.replace("switchport trunk allowed vlan ","").trimstart()
        }
      if ($line.contains("switchport trunk native vlan") )
        {#switchport trunk allowed vlan 1105,1110-1112
         $info | Add-Member NoteProperty tnativevlan $line.replace("switchport trunk native vlan ","").trimstart()
        }
       if ($line.contains("switchport access vlan") )
        {#switchport trunk allowed vlan 1105,1110-1112
         $info | Add-Member NoteProperty anativevlan $line.replace("switchport access vlan ","").trimstart()
        }
        if ($line.contains("channel-group") )
        {
        $chgrp = $line.split(" ")[2]
        $info | Add-Member NoteProperty chgrp $chgrp 
        }
    
    }
    if ($line.startswith("interface") )
    { 
      #Write-Host "testing for interface" 
      $GOTVLAN = $true
      $bangs=0
      $intname=$line.replace("interface ","") 
      $intname=$intname.replace("TenGigabitEthernet","TE")
      $intname=$intname.replace("GigabitEthernet","GI")
      $intname=$intname.replace("Vlan","VL")
      $intname=$intname.replace("Port-channel","PO")
      $intname=$intname.replace("FastEthernet", "FA") 
      $info = New-Object object
      $info | Add-Member NoteProperty int $intname
      #Write-Host $intname "it was" 
      } 
  }
  #Write-Host "now print out what we got"
  #foreach ($mydata in $runint) {
  # Write-Host "." $mydata.int "," $mydata.mode "," $mydata.tnativevlan "," $mydata.anativevlan "," $mydata.allowedvlan
  # }
  
Write-Host "."

# allign the data
  foreach ($x in $VLANS ) {
   foreach ($y in $STPinfo ) {
    if ($y.vlanid -eq $x.vlanid ) {
    $x | Add-Member NoteProperty pri $y.pri
    $x | Add-Member NoteProperty root $y.root
    $x | Add-Member NoteProperty rcost $y.rcost
    }
   }
  }
  foreach ( $x in $L3info) {
    foreach ($y in $hsrp)
     {
     #Write-Host "im in the HSRP and L3 merge" $x.int "," $y.int "," $y.grp "," $y.pri "," $y.state "," $y.preempt "," $y.ip 
     if ($y.int -eq $x.int) {
      $x | Add-Member NoteProperty grp $y.grp
      $x | Add-Member NoteProperty pri $y.pri
      $x | Add-Member NoteProperty state $y.state
      $x | Add-Member NoteProperty preempt $y.preempt
      $x | Add-Member NoteProperty vip $y.ip 
      }}}
   foreach ( $x in $MYINT) {
    foreach ( $y in $MYCDP) {
     if ($y.int -eq $x.int ) {
        $x | Add-Member NoteProperty neiname $y.neiname
        $x | Add-Member NoteProperty cdpfarint $y.farint
        }
        }
    foreach ( $z in $runint ) {
        if ($z.int -eq $x.int ) {
        $x | Add-Member NoteProperty  mode $z.mode
        $x | Add-Member NoteProperty  tnativevlan $z.tnativevlan
        $x | Add-Member NoteProperty  anativevlan $z.anativevlan
        $x | Add-Member NoteProperty  allowedvlan $z.allowedvlan
        $x | Add-Member NoteProperty  chgrp       $z.chgrp
         }
        }    
     #Write-Host "combined int info is" $x.int "," $x.neiname ", " $x.desfarint "," $x.cdpfarint ","  $x.mode "," $x.tnativevlan "," $x.anativevlan "," $x.allowedvlan
    }
    Write-Host "."
    #Write-Host "I'm here"
    #  foreach ($wh in $L3info)
    #  { Write-Host "L3info" $wh.int "," $wh.ip  "," $wh.vip "," $wh.grp "," $wh.state  "," $wh.pri  "," $wh.preempt}  
    
 $hostdata = ($sysinfo, $VLANS, $Etherchnl , $L3info, $MYINT ) 
  return $hostdata
}

Function BuildSWInfo ( $sheet , $A , $B )  {

 ($Asysinfo, $AVLANS, $AEtherchnl ,  $AL3info, $AMYINT) =$A
 ($Bsysinfo, $BVLANS, $BEtherchnl ,  $BL3info, $BMYINT) =$B
 Write-Host "Building C3560 AMP Switch area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Name",
      "IP Address",
      "Model",
      "Serial",
      "Username",
      "Password",
      "OS level")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "C3560 Ethernet AMP Switch Information" $row $col
 ### Details/Data
   $row += 1 
   $sheet.Cells.Item($row, $startcol)      = $Asysinfo.hostname
   $sheet.Cells.Item($row, $startcol+1)    = $Asysinfo.ip
   $sheet.Cells.Item($row, $startcol+2)    = $Asysinfo.model
   $sheet.Cells.Item($row, $startcol+3)    = $Asysinfo.serial
   $sheet.Cells.Item($row, $startcol+4)    = $Uname
   $sheet.Cells.Item($row, $startcol+5)    = $Pword 
   $sheet.Cells.Item($row, $startcol+6)    = $Asysinfo.OSver
   $row += 1 
   $sheet.Cells.Item($row, $startcol)      = $Bsysinfo.hostname
   $sheet.Cells.Item($row, $startcol+1)    = $Bsysinfo.ip
   $sheet.Cells.Item($row, $startcol+2)    = $Bsysinfo.model
   $sheet.Cells.Item($row, $startcol+3)    = $Bsysinfo.serial 
   $sheet.Cells.Item($row, $startcol+4)    = $Uname 
   $sheet.Cells.Item($row, $startcol+5)    = $Pword
   $sheet.Cells.Item($row, $startcol+6)    = $Bsysinfo.OSver
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
Write-Host "."
return $row , $col 
}

function BuildSWVLANInfo ($sheet, $A ,$B ) {
 Write-Host "Building C3560 VLAN   area ..." -NoNewline
 
  ($Asysinfo, $AVLANS, $AEtherchnl ,  $AL3info, $AMYINT) =$A
  ($Bsysinfo, $BVLANS, $BEtherchnl ,  $BL3info, $BMYINT) =$B
 
  # first join the vlan stuff
  
   $VLANS = @()
   foreach ($VL in $AVLANS ) 
    {
     $me = New-Object object
     $me | Add-Member NoteProperty vlanid $VL.vlanid
     $VLANS += $me
     #Write-Host "A side stuff" $VL.pri
     }
    foreach ($VL in $BVLANS ) 
    {
     $me = New-Object object
     $me | Add-Member NoteProperty vlanid $VL.vlanid
     $VLANS += $me
     }
  #foreach ( $both_VL in $VLANS ) { Write-Host "both vlans are" $both_VL.vlanid }
    $VLANS = $VLANS | Sort-Object vlanid -Unique |Sort-Object @{expression={[double]$_.'vlanid'}}
  #foreach ( $both_VL in $VLANS ) { Write-Host "both vlans are post unique" $both_VL.vlanid }

    foreach ( $both_VL in $VLANS )
    {
    foreach ($VL in $AVLANS ) 
        {
        if ($both_VL.vlanid -eq $VL.vlanid ) 
        { 
        $both_VL | Add-Member NoteProperty Aside  $VL.vlanname
        $both_VL | Add-Member NoteProperty APrio  $VL.pri
        $both_VL | Add-Member NoteProperty Aroot  $VL.root
        $both_VL | Add-Member NoteProperty APcost $VL.rcost
        }   
       }
        foreach ($VL in $BVLANS ) 
        {
        if ($both_VL.vlanid -eq $VL.vlanid ) 
        { 
        $both_VL | Add-Member NoteProperty Bside  $VL.vlanname
        $both_VL | Add-Member NoteProperty BPrio  $VL.pri
        $both_VL | Add-Member NoteProperty Broot  $VL.root
        $both_VL | Add-Member NoteProperty BPcost $VL.rcost
        # Write-Host "BVLANS" $VL.vlanname "," $VL.pri "," $VL.root "," $VL.rcost 
        }   
       }
      }
     
    
        Write-Host "." -NoNewline
    #}
      $VLANS = $VLANS |Sort-Object @{expression={[double]$_.'vlanid'}}
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
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "AMP C3560 Ethernet  VLAN Information" $row $col
 ### Details/Data
   $row += 1  
     
    foreach ( $sp in $VLANS )
      {
      Write-Host "."  -NoNewline 
   #   Write-Host "VLAN Lists" $sp.id $sp.Aside $sp.Bside
      $sheet.Cells.Item($row, $startcol)    = $sp.vlanid
      
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

function BuildSWPcInfo ($sheet, $A ,$B ) {
 Write-Host "Building C3560 Port Channel   area ..." -NoNewline
  # first join the PC stuff
  ($Asysinfo, $AVLANS, $AEtherchnl ,  $AL3info, $AMYINT) =$A
  ($Bsysinfo, $BVLANS, $BEtherchnl ,  $BL3info, $BMYINT) =$B
  
   $PortChannels = @()
   foreach ($loop_1 in $AEtherchnl ) 
        {
        $Y = New-Object object
        $Y | Add-Member NoteProperty id $loop_1.pgrpno
        $PortChannels += $Y
        }
     foreach ($loop_1 in $BEtherchnl ) 
        {
        $Y = New-Object object
        $Y | Add-Member NoteProperty id $loop_1.pgrpno
       $PortChannels += $Y
        }
   # foreach ( $ME in $PortChannels ) {Write-Host "lookin for this" $ME.id }
   $PortChannels = $PortChannels | Sort-Object id -Unique |Sort-Object @{expression={[double]$_.'id'}}
   # foreach ( $ME in $PortChannels ) {Write-Host "lookin for this after unique " $ME.id }

   # now add the per side stuff. first add VPC
   foreach ( $currentPc in $PortChannels )
   {
   Write-Host "." -NoNewline
   foreach ($loop_1 in $AEtherchnl ) 
        {
        if ( $currentPc.id -eq $loop_1.pgrpno )
        {
         $currentPc | Add-Member NoteProperty AIntfName $loop_1.pgrpint
         $currentPc | Add-Member NoteProperty Amembers  $loop_1.pgrpmembers 
         foreach ( $loop_2 in $AMYINT ) 
       		{ 
       		#Write-Host "in pc area looking at the allowed vlans" $loop_2.int ", " $loop_2.allowedvlan
       	   if ($loop_2.int -eq ("PO"+$currentPc.id) ) 
       	   { 
       	    $thevlan= $loop_2.allowedvlan + $loop_2.anativevlan
       	   $currentPc | Add-Member NoteProperty Avlan $thevlan }
          }
         }
      # Below one closes out the Switch match with the $portChannels
       }
   foreach ($loop_1 in $BEtherchnl ) 
        {
        if ( $currentPc.id -eq $loop_1.pgrpno )
        {
         $currentPc | Add-Member NoteProperty BIntfName $loop_1.pgrpint
         $currentPc | Add-Member NoteProperty Bmembers $loop_1.pgrpmembers 
       foreach ( $loop_2 in $BMYINT ) 
       		{ 
       		#Write-Host "in pc area looking at the allowed vlans" $loop_2.int ", " $loop_2.allowedvlan
       	   if ($loop_2.int -eq ("PO"+$currentPc.id) ) 
       	   { $thevlan= $loop_2.allowedvlan + $loop_2.anativevlan
       	   $currentPc | Add-Member NoteProperty Bvlan $thevlan }
          }
         }
      # Below one closes out the Switch match with the $portChannels
       }
    # below one closes out the $PortChannels
    }
   # foreach ($w in $PortChannels) 
   # { Write-Host "pclist " $w.id ","$w.AintfName ", "$w.Amembers "," $w.Avlan ","$w.BintfName ", "$w.Bmembers "," $w.Bvlan }    
     Write-Host "!" -NoNewline
   $PortChannels = $PortChannels |Sort-Object @{expression={[double]$_.'id'}}
    # now built the table 
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Port-Channel",
      "Interface Name",
      "",
      "Member Vlans",
      "",
      "Member Interfaces",
      "",
      "VCE Purpose")
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "AMP C3560 Ethernet PortChannel Switch Information" $row $col
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

       if ( $sp.AIntfName -eq $sp.BIntfName ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+1)  = $sp.AIntfName
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+1)  = $sp.AIntfName
      $sheet.Cells.Item($row, $startcol+2)  = $sp.BIntfName
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
       { $Purpose = "From AMP-SW-A to N5kA/B"}      
       "38"
       { $Purpose = "From AMP-SW-B to N5kA/B"}       
       "10"
       { $Purpose = "Amp Link"}      
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

function BuildSWL3Info ($sheet, $A ,$B ) {
 Write-Host "Building C3560 Layer3   area ..." -NoNewline
  # first join the PC stuff
  ($Asysinfo, $AVLANS, $AEtherchnl ,  $AL3info, $AMYINT) =$A
  ($Bsysinfo, $BVLANS, $BEtherchnl ,  $BL3info, $BMYINT) =$B
  
   $L3intf = @()
   foreach ($loop_1 in $AL3info ) 
        {
        $Y = New-Object object
        $Y | Add-Member NoteProperty id $loop_1.int
        Write-Host "." -NoNewline
        $L3intf += $Y
        }
     foreach ($loop_1 in $BL3info ) 
        {
        $Y = New-Object object
        $Y | Add-Member NoteProperty id $loop_1.int
        Write-Host "." -NoNewline
       $L3intf += $Y
        }
    #foreach ( $ME in $L3intf ) {Write-Host "lookin for this" $ME.id }
   $L3intf = $L3intf | Sort-Object id -Unique |Sort-Object @{expression={[double]$_.'id'}}
    #foreach ( $ME in $L3intf ) {Write-Host "lookin for this after unique " $ME.id }

   # now add the per side stuff. first add VPC
   foreach ( $currentL3 in $L3intf )
   {
   Write-Host "." -NoNewline
   foreach ($loop_1 in $AL3info ) 
        {
        if ( $currentL3.id -eq $loop_1.int )
        {
         $currentL3 | Add-Member NoteProperty Aip $loop_1.ip
         $currentL3 | Add-Member NoteProperty Agrp $loop_1.grp
         $currentL3 | Add-Member NoteProperty Apri $loop_1.pri 
         $currentL3 | Add-Member NoteProperty Astate $loop_1.state 
         $currentL3 | Add-Member NoteProperty Apreempt $loop_1.preempt
         $currentL3 | Add-Member NoteProperty Avip $loop_1.vip
         }
      # Below one closes out the Switch match with the $portChannels
       }
   foreach ($loop_1 in $BL3info ) 
        {
        if ( $currentL3.id -eq $loop_1.int )
        {
         $currentL3 | Add-Member NoteProperty Bip $loop_1.ip
         $currentL3 | Add-Member NoteProperty Bgrp $loop_1.grp
         $currentL3 | Add-Member NoteProperty Bpri $loop_1.pri 
         $currentL3 | Add-Member NoteProperty Bstate $loop_1.state 
         $currentL3 | Add-Member NoteProperty Bpreempt $loop_1.preempt
         $currentL3 | Add-Member NoteProperty Bvip $loop_1.vip
         }
      # Below one closes out the Switch match with the $portChannels
       }
    # below one closes out the $PortChannels
    }
        Write-Host "!" -NoNewline
   $L3intf = $L3intf |Sort-Object @{expression={[double]$_.'id'}}
    # now built the table 
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Interface",
      "Virtual IP",
      "",
      "Real IP",
      "",
      "state/priority/Prempt",
      "",
      "Group",
      "")
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "AMP C3560 Layer3 Switch Information" $row $col
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
    $range  = $sheet.Range($sheet.Cells.Item($row, $col+7), $sheet.Cells.Item($row,$col+8))
    $range.Merge($true)
    $range.HorizontalAlignment = 3
    $range  = $sheet.Range($sheet.Cells.Item($row-1, $col), $sheet.Cells.Item($row,$col+8))
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
          $sheet.Cells.Item($row, $startcol+7)    = "Switch A"
          $sheet.Cells.Item($row, $startcol+8)    = "Switch B"
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol), $sheet.Cells.Item($row,$startcol+8))
      $range.Interior.Color      = $ltBlue
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      $row += 1
      foreach ( $sp in $L3intf )
      {
      Write-Host "."  -NoNewline 
      $sheet.Cells.Item($row, $startcol)    = $sp.id

       if ( $sp.Aip -eq $sp.Bip ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2))
       #$range.Merge($true)
       $range.Interior.Color      = $Yellow
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+1)  = $sp.Aip
       $sheet.Cells.Item($row, $startcol+1)  = $sp.Bip
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+1)  = $sp.Aip
      $sheet.Cells.Item($row, $startcol+2)  = $sp.Bip
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+1), $sheet.Cells.Item($row,$startcol+2)) 
      #$range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
         
      if ( $sp.Avip -eq $sp.Bvip ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+3), $sheet.Cells.Item($row,$startcol+4))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+3)  = $sp.Avip
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+3)  = $sp.Avip
      $sheet.Cells.Item($row, $startcol+4)  = $sp.Bvip
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+3), $sheet.Cells.Item($row,$startcol+4)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
     $sheet.Cells.Item($row, $startcol+5)  = $sp.Astate + "/" +$sp.Apri+ "/" +$sp.Apreempt 
     $sheet.Cells.Item($row, $startcol+6)  = $sp.Bstate + "/" +$sp.Bpri+ "/" +$sp.Bpreempt
      if ( $sp.Agrp -eq $sp.Bgrp ) {
       # if they are the same merge them, use the a switch data and move on    
       $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+7), $sheet.Cells.Item($row,$startcol+8))
       $range.Merge($true)
       $range.HorizontalAlignment = 3
       $sheet.Cells.Item($row, $startcol+7)  = $sp.Agrp
       }
		else {
		#otherwise put both in and make it yellow
      $sheet.Cells.Item($row, $startcol+7)  = $sp.Agrp
      $sheet.Cells.Item($row, $startcol+8)  = $sp.Bgrp
      $range  = $sheet.Range($sheet.Cells.Item($row, $startcol+7), $sheet.Cells.Item($row,$startcol+8)) 
      $range.Interior.Color      = $Yellow
      $range.HorizontalAlignment = 3
      $range.Font.Bold           = $true
      }
 
      $row += 1
      }
    $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    # also need to add teh abilityt to autosize and line wrap.
    $row += 2 
 Write-Host "."
$row, $col 
}



function BuildSWEthInfo ($sheet, $A ,$B ) {
 Write-Host "Building C3560 Ether Xconn area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

  ($Asysinfo, $AVLANS, $AEtherchnl ,  $AL3info, $AMYINT) =$A
  ($Bsysinfo, $BVLANS, $BEtherchnl ,  $BL3info, $BMYINT) =$B
  

Write-Host "."

     
     $colHeaders = @(
      "Port",
      "Remote Device",
      "Remote Port",
      "Mode",
      "VLANS`nnative or allowed",
      "Etherchannel`nPortChannel",
      "Interface Use")
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "AMP C3560 Switch A xconnect Information" $row $col
 ### Details/Data
   $row += 1       
          #Write-Host "Switch A stuff" $sp.port $sp.rmdid $sp.rmport $sp.mode $sp.vlan $sp.portchnl 
          
        foreach ($w in $AMYINT ) 
        {
         Write-Host "." -NoNewline
         if ($w.intstate -eq "up" -or $w.descr -or $w.neiname ) {
         if ( $w.int.contains("PO") -or $w.int.contains("VL")) { continue} 
        $sheet.Cells.Item($row, $startcol)    = $w.int
        $sheet.Cells.Item($row, $startcol+1)  = $w.neiname
        $sheet.Cells.Item($row, $startcol+2)  = $w.cdpfarint
        $sheet.Cells.Item($row, $startcol+3)  = $w.mode
        $sheet.Cells.Item($row, $startcol+4)  = $w.anativevlan + $w.allowedvlan
        $sheet.cells.item($row, $startcol+5)  = $w.chgrp 
        $sheet.Cells.Item($row, $startcol+6)  = $w.desfarint 
        $row += 1
        }
        }
      #end of int_brief for A
      
     $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2 
  # Write-Host $row $col 
  ##### if you want to bump it to the right instead of below
  # $row = $startrow
  # $col = $startcol+8
   $startrow = $row
   $startcol = $col
  #####
    #Write-Host $row $col 
 
    $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "AMP C3560 Switch B xconnect Information" $row $col
    ### Details/Data
   $row += 1 

      foreach ($w in $BMYINT ) 
        {
         Write-Host "." -NoNewline
         if ($w.intstate -eq "up" -or $w.descr -or $w.neiname ) {
          if ( $w.int.contains("PO") -or $w.int.contains("VL") ) { continue}  
        $sheet.Cells.Item($row, $startcol)    = $w.int
        $sheet.Cells.Item($row, $startcol+1)  = $w.neiname
        $sheet.Cells.Item($row, $startcol+2)  = $w.cdpfarint
        $sheet.Cells.Item($row, $startcol+3)  = $w.mode
        $sheet.Cells.Item($row, $startcol+4)  = $w.anativevlan + $w.allowedvlan
        $sheet.cells.item($row, $startcol+5)  = $w.chgrp 
        $sheet.Cells.Item($row, $startcol+6)  = $w.desfarint 
        $row += 1
        }
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

### first build the foundation for the Excel worksheets
################################################################################
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

### 

if ($Readin) 
{ 
     $Uname = "Offline Build"
     $Pword = "Offline Build"  
if ( Test-Path $hosta )
    {
    Write-Host "Found the file, Now reading."
   $hostacmds = Get-Content $hosta  
   $deviceaip = "Offline see L3 table"
   $hostAname = ($hostacmds | Select-String "uptime" | %{$_ -Split" "})[0]
 
  Write-Host "I am hostname " $hostAname
    } else { 
      Write-Host "file specified not found"
      break }
if ( Test-Path $hostb )
   {
   Write-Host "Found the file, Now reading."

  $hostbcmds = ( Get-Content $hostb )
 $devicebip = "Offline see L3 table"
  $hostBname = ($hostbcmds | Select-String "uptime" | %{$_ -Split" "})[0]
  } else { 
      Write-Host "file specified not found"
   break }
}
else {
   if (($hosta) -and ($hosta -as [ipaddress])){
       $hostCreds = Get-Credential admin
     if ($hostCreds) 
     {
      $Uname = $hostCreds.GetNetworkCredential().Username
      $Pword = $hostCreds.GetNetworkCredential().Password
      $hostacmds , $hostarun = getHostInfo $Uname $Pword $hosta      
      $deviceaip = $hosta
      }
    else {"Please provide a valid Host IP username and  Password"}  
    }
   if (($hostb) -and ($hostb -as [ipaddress])){
      #  $hostbCreds = Get-Credential admin
      if ($hostCreds) 
     {
     $Uname = $hostCreds.GetNetworkCredential().Username
     $Pword = $hostCreds.GetNetworkCredential().Password
     $hostbcmds , $hostbrun = getHostInfo $Uname $Pword $hostb
     $devicebip = $hostb
    }
    else {"Please provide a valid Host IP username and  Password"}}
  if ($noWrite) { Write-Host "Not saving collection" }
     else {
    # get cluster name for fileto save as
    # build date output get-date -Format yyyy-MM-dd-HHmm
   $THETIME = Get-Date -uformat %Y%m%d%m-%H%M
     $hostAname = ($hostacmds | Select-String "uptime" | %{$_ -Split" "})[0]
     $outfilea     = $hostAname + "-"  + $THETIME + ".data"
     $outfilearun  = $hostAname  + "-" + $THETIME + "-running-cfg.txt"
     $hostBname = ($hostbcmds | Select-String "uptime" | %{$_ -Split" "})[0]
     $outfileb    = $hostBname + "-" + $THETIME + ".data"
     $outfilebrun = $hostBname + "-" + $THETIME + "-running-cfg.txt"
     Write-Host "saving data as" $outfilea $outfileb
   
      $hostacmds | Out-File  $outfilea -Encoding ascii
      $hostbcmds | Out-File  $outfileb -Encoding ascii

     $hostarun | Out-File  $outfilearun
     $hostbrun | Out-File  $outfilebrun }
#end of else for reaadin
}
#Write-Host "my hostacmds is this many lines" $hostacmds.length
$hostadata = buildHostdata $hostacmds $hostacmds $deviceaip
$hostbdata = buildHostdata $hostbcmds $hostbcmds $devicebip

# Fire off Excel COM object
#

if ($noexcel ) { 
Write-Host "you chose no excel output, now exiting."
break }

Write-Host "Creating Excel COM Object... "
$erroractionpreference = "SilentlyContinue"
$excel         = New-Object -ComObject Excel.Application
$excel.visible = $false
################################ Create Array Details Worksheet ######################################
Write-Host "Creating Compute Information Page "
$wb            = $excel.Workbooks.Add()
#
$sheet1        = $wb.Worksheets.Item(1) 
$sheet1.Name   = "AMP_Eth"
$wb.Worksheets("AMP_Eth").Activate


### start in cell B2
[int]$row = 2
[int]$col = 2


#   $row, $col = BuildUCSFIInfo     $sheet1 $ClvArray $Clfarray
$row, $col = BuildSWInfo $sheet1 $hostadata $hostbdata
$row, $col = BuildSWVLANInfo $sheet1 $hostadata $hostbdata
$row, $col = BuildSWPcInfo $sheet1 $hostadata $hostbdata
$row, $col = BuildSWL3Info $sheet1 $hostadata $hostbdata
$row, $col = BuildSWEthInfo $sheet1 $hostadata $hostbdata
#######################################################################################################
# # # # # # # # # # # # # # # # Display Spreadsheet # # # # # # # # # # # # # # # # # # # # # # 


Write-Host "Complete - Displaying Excel Spreadsheet (be sure to save it)"
$excel.visible = $true
Write-Host " "
Write-Host " "
# $sheet1.SaveAs("what.xlsx")
