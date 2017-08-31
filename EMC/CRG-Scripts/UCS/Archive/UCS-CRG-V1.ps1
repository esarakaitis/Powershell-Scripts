##################################################################################
#                                                                                # 
# UCS report tool                                                                #
# This script is intended to be used for creating the CRG document to hand over  #
#   to the customer for final documentation. To run this script requires that    #
#   you are able to ping the UCS Fabric UCS Clusters and have Excel installed.   #
#                                                                                #
#  Version Update:                                                               #
#  1.0 Robert Auvil 30-Jan-2012 _ Script created                                 #
#  1.2 Robert Auvil 31-Jan-2012 _ updated Excel area Headers                     #
#  1.5 Robert Auvil 31-Jan-2012 _ worked on License part                         #
#  1.6 Robert Auvil 31-Jan-2012 _ worked on error handling, and Wiremap          #
#  1.7 Robert Auvil  2-Feb-2012 _ build ability for saving data for offline      # 
#                               _ processing                                     #
##################################################################################


param
(
   [parameter(Mandatory = $true)]
   [string]
   $url,
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

### here is the stuff for xmlapi

function ucsPost($url,$data) {
    if ($global:nossl){
        $u = "http://"+ $url +"/nuova"
    }
    else {
        $u = "https://"+ $url +"/nuova"
    }
    $request = [System.Net.HttpWebRequest] [System.Net.HttpWebRequest]::Create($u)
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $request.Method = "POST"
    $request.ContentType = "text/xml"
    $sendData = new-object System.IO.StreamWriter($request.GetRequestStream())
    $sendData.Write($data)
    $sendData.Close()
    $response = $request.GetResponse()
    $sr = new-object System.IO.StreamReader($response.GetResponseStream())
    $xml = [xml] $sr.ReadToEnd()
    return $xml
}

function ucsLogin($url, $inName, $inPassword) {
   Write-Host "Logging into UCSM at " $url
   $aaaLogin = "<aaaLogin inName='" + $inName + "' inPassword='" + $inPassword + "' />"
   $xml = ucsPost $url $aaaLogin
   $outCookie = $xml.aaaLogin.outCookie
   return $outCookie
}

function ucsLogout($url, $inCookie) {
    $aaaLogout = "<aaaLogout inCookie='" + $inCookie + "' />"
    $xml = ucsPost $url $aaaLogout
    $outStatus = $xml.aaaLogout.outStatus
    return $outStatus
}

function getUCSFcData ($url, $inCookie) {
    Write-Host "Retrieving UCS Cabling Details ..." 
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='fcPIo'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
#    etherPIo (list of ports, can be used for IOM and Port channel associations)
#      chassisId, dn, epDn, mac, mode, peerDn, peerPortId, PeerSlotId, PortId, SlotId, ifRole
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
     # Write-Host  $sp.dn $sp.switchId $sp.SlotId $sp.PortId $sp.wwn $sp.adminState $sp.ifRole $sp.chassisId $sp.epDn $sp.mode  "<sp.mode sp.peerDn>"  $sp.peerDn $sp.PeerSlotId $sp.peerPortId 
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty switchId $sp.switchId
        $ucs | Add-Member NoteProperty SlotId $sp.SlotId
        $ucs | Add-Member NoteProperty PortId $sp.PortId
        $ucs | Add-Member NoteProperty wwn $sp.wwn
        $ucs | Add-Member NoteProperty adminState $sp.adminState
        $ucs | Add-Member NoteProperty ifRole $sp.ifRole
        $ucs | Add-Member NoteProperty chassisId $sp.chassisId
        $ucs | Add-Member NoteProperty epDn $sp.epDn
        $ucs | Add-Member NoteProperty mode $sp.mode
        $ucs | Add-Member NoteProperty peerDn $sp.peerDn
        $ucs | Add-Member NoteProperty PeerSlotId $sp.PeerSlotId
        $ucs | Add-Member NoteProperty PeerPortId $sp.PeerPortId        
        $a += $ucs
    }
     return $a | Sort-Object switchId , @{expression={[double]$_.'SlotId'}} , @{expression={[double]$_.'PortId'}}
}

function BuildUCSFcData ( $sheet, $FcArray ) {
   Write-Host "Building FC Interconnect area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Port",
      "Port WWN used to associate later",
      "Type",
      "Connected Device",
      "Connected Port")
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series FC Interconnect Information" $row $col
   ### Details/Data
   $row += 1

   foreach ($x in $FcArray ) 
    {
     Write-Host "." -NoNewLine 
    $sheet.Cells.Item($row, $startcol)    = "FI-" + $x.switchId +" "+ $x.SlotId + "/" + $x.PortId
    $sheet.Cells.Item($row, $startcol+1)  = $x.wwn
    $sheet.Cells.Item($row, $startcol+2)  = $x.ifRole
    if ( $x.ifRole -eq "server" ) 
    { 
    $sheet.Cells.Item($row, $startcol+3)  = "Chassis " + $x.chassisId
    $sheet.Cells.Item($row, $startcol+4)  = "IOM " + $x.PeerSlotId + "/" + $x.PeerPortId 
    }
    if ( $x.ifRole -eq "network" )
    { 
    $sheet.Cells.Item($row, $startcol+3)  = ( $x.epDn -split '/')[3]
    $sheet.Cells.Item($row, $startcol+4)  = "UCSM Uplink"
    }
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
   Write-Host "."
    $row, $col
}

function getUCSEtherData ($url, $inCookie) {
    Write-Host "Retrieving UCS Cabling Details ..." 
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='etherPIo'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
#    etherPIo (list of ports, can be used for IOM and Port channel associations)
#      chassisId, dn, epDn, mac, mode, peerDn, peerPortId, PeerSlotId, PortId, SlotId, ifRole
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
    #  Write-Host  $sp.dn $sp.switchId $sp.SlotId $sp.PortId $sp.mac  $sp.ifRole $sp.chassisId $sp.epDn $sp.mode  "<sp.mode sp.peerDn>"  $sp.peerDn $sp.PeerSlotId $sp.peerPortId 
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty switchId $sp.switchId
        $ucs | Add-Member NoteProperty SlotId $sp.SlotId
        $ucs | Add-Member NoteProperty PortId $sp.PortId
        $ucs | Add-Member NoteProperty mac $sp.mac
        $ucs | Add-Member NoteProperty ifRole $sp.ifRole
        $ucs | Add-Member NoteProperty chassisId $sp.chassisId
        $ucs | Add-Member NoteProperty epDn $sp.epDn
        $ucs | Add-Member NoteProperty mode $sp.mode
        $ucs | Add-Member NoteProperty peerDn $sp.peerDn
        $ucs | Add-Member NoteProperty PeerSlotId $sp.PeerSlotId
        $ucs | Add-Member NoteProperty PeerPortId $sp.PeerPortId        
        $a += $ucs
    }
     return $a | Sort-Object switchId , @{expression={[double]$_.'SlotId'}} , @{expression={[double]$_.'PortId'}}
}

function BuildUCSEtherData ( $sheet, $EthArray ) {
   Write-Host "Building Eth Interconnect area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Port",
      "Port MAC used to associate later",
      "Type",
      "Connected Device",
      "Connected Port")
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series Eth Interconnect Information" $row $col
   ### Details/Data
   $row += 1

   foreach ($x in $EthArray ) 
    {
     Write-Host "." -NoNewLine 
    $sheet.Cells.Item($row, $startcol)    = "FI-" + $x.switchId +" "+ $x.SlotId + "/" + $x.PortId
    $sheet.Cells.Item($row, $startcol+1)  = $x.mac
    $sheet.Cells.Item($row, $startcol+2)  = $x.ifRole
    if ( $x.ifRole -eq "server" ) 
    { 
    $sheet.Cells.Item($row, $startcol+3)  = "Chassis " + $x.chassisId
    $sheet.Cells.Item($row, $startcol+4)  = "IOM " + $x.PeerSlotId + "/" + $x.PeerPortId 
    }
    if ( $x.ifRole -eq "network" )
    { 
    $sheet.Cells.Item($row, $startcol+3)  = ( $x.epDn -split '/')[3]
    $sheet.Cells.Item($row, $startcol+4)  = "UCSM Uplink"
    }
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
   Write-Host "."
    $row, $col
}

function getUCSLicenseData ($url, $inCookie) {
    Write-Host "Retrieving UCS License Details ..."
 # tried others but no luck sys, sys/license, licenseEp,
 # these work: licenseFeature browsing via UCSM emulator objects.
 #             licenseInstance (get licesnes) use cisco Poweshell plugin to get more cmd (Get-License -XML) 
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='licenseInstance'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
    # These are for licenseFeature
    #Write-Host $sp.dn $sp.descr $sp.gracePeriod $sp.initId $sp.name $sp.type $sp.vendor $sp.version
    # These are for LicenseInstance (gracePeriodUsedSpecified is a true/false)
    #Write-Host $sp.dn "," $sp.scope "," $sp.usedQuant "," $sp.operState "," $sp.gracePeriodUsed "," $sp.gracePeriodUsedSpecified "," $sp.absQuant "," $sp.defQuant "," $sp.text "," $sp.isPresent "," $sp.status "," $sp.feature
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty scope $sp.scope
        $ucs | Add-Member NoteProperty usedQuant $sp.usedQuant
        $ucs | Add-Member NoteProperty operState $sp.operState
        $ucs | Add-Member NoteProperty gracePeriodUsed $sp.gracePeriodUsed
        $ucs | Add-Member NoteProperty gracePeriodUsedSpecified $sp.gracePeriodUsedSpecified
        $ucs | Add-Member NoteProperty absQuant $sp.absQuant
        $ucs | Add-Member NoteProperty defQuant $sp.defQuant
        $ucs | Add-Member NoteProperty text $sp.text
        $ucs | Add-Member NoteProperty isPresent $sp.isPresent
        $ucs | Add-Member NoteProperty status $sp.status
        $ucs | Add-Member NoteProperty feature $sp.feature
        $a += $ucs
    }
    return $a | Sort-Object scope
}

function BuildUCSLicense ( $sheet, $licArray ) {
   Write-Host "Building License area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Fabric",
      "Feature type",
      "Feature type",
      "Time left",
      "Defined Qty",
      "Absolute Qty",
      "Is Present",
      "Total Used Qty")      
      
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series License Information" $row $col
 ### Details/Data
   $row += 1
   
 foreach ($li in $licArray ) 
   {
    Write-Host "." -NoNewLine 
   #Write-Host  $cl.scope $li.feature $li.operState $li.defQuant $li.usedQuant
    $sheet.Cells.Item($row, $startcol)    = $li.scope
    $sheet.Cells.Item($row, $startcol+1)  = $li.feature
    $sheet.Cells.Item($row, $startcol+2)  = $li.operState
    $sheet.Cells.Item($row, $startcol+3)  = $li.gracePeriodUsed
    $sheet.Cells.Item($row, $startcol+4)  = $li.defQuant
    $sheet.Cells.Item($row, $startcol+5)  = $li.absQuant
    $sheet.Cells.Item($row, $startcol+6)  = $li.isPresent
    $sheet.Cells.Item($row, $startcol+7)  = $li.usedQuant
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
  Write-Host "."
    $row, $col
}

function getUCSCClusterInfo ($url, $inCookie) {
    Write-Host "Retrieving UCS Cluster UCSM Details ..."
    # grab cluster data.
    # first get FW level
    $myinput = "<configResolveClass cookie='" + $inCookie + "'inHierarchical='false' classId='firmwareRunning'>'
    <inFilter><eq class='firmwareRunning'property='dn' value='sys/mgmt/fw-system' /></inFilter></configResolveClass>"
    $xml = ucsPost $url $myinput
    foreach ( $sp in $xml.configResolveClass.outConfigs.childnodes) 
       {
        #     Write-Host $sp.dn $sp.deployment $sp.packageVersion $sp.type $sp.version 
    	$Clfw = $sp.version } 
    # now get Cluster details
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='topSystem'></configResolveClass>"
     $xml = ucsPost $url $myinput
     $Clusterstuff =@()
      foreach ( $sp in $xml.configResolveClass.outConfigs.childnodes) {
        # Write-Host $sp.dn $sp.name $sp.address $Clfw
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty name $sp.name
        $ucs | Add-Member NoteProperty IP $sp.address
        $ucs | Add-Member NoteProperty Firm $Clfw 
        $Clusterstuff += $ucs
        }
return $Clusterstuff | Sort-Object dn
}

function getUCSFIInfo ($url, $inCookie) {
    Write-Host "Retrieving UCS Cluster FI Details ..."
    # now get FI firmware details
      $myinput = "<configResolveClass cookie='" + $inCookie + "'inHierarchical='false' classId='firmwareRunning'>'
    <inFilter><wcard class='firmwareRunning'property='type' value='switch-' /></inFilter></configResolveClass>"
    $xml = ucsPost $url $myinput
    $FiFW =@()
    foreach ( $sp in $xml.configResolveClass.outConfigs.childnodes) {
      #  Write-Host $sp.dn $sp.deployment $sp.packageVersion $sp.type $sp.version 
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty deployment $sp.deployment
        $ucs | Add-Member NoteProperty pkg $sp.packageVersion
        $ucs | Add-Member NoteProperty type $sp.type
        $ucs | Add-Member NoteProperty version $sp.version 
        $FiFW += $ucs
        }
     #  get the FI details
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='networkElement'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $FiData = @()
   # N10-S6200 = 6240XP
   # N10-S6100 = 6120XP
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        #Write-Host $sp.dn $sp.id $sp.name $sp.serial $sp.model $sp.oobIfIp
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty id $sp.id
        $ucs | Add-Member NoteProperty name $sp.name
        $ucs | Add-Member NoteProperty serial $sp.serial
        $ucs | Add-Member NoteProperty model $sp.model
        $ucs | Add-Member NoteProperty IP $sp.oobIfIp
        $ucs | Add-Member NoteProperty Kernel "/mgmt/fw-kernel" 
        $ucs | Add-Member NoteProperty system "/mgmt/fw-system"
      $FiData += $ucs        
    } 
  
    foreach ($Fi in $FiData) 
           {
           $Fikernel = $Fi.dn+$Fi.Kernel
           $FiSystem = $Fi.dn+$Fi.system
           #Write-Host "and they are" $Fikernel $FiSystem
           foreach ($Fw in $FiFW) 
              { 
             # Write-Host "in FiFW loop " $Fw.dn $Fikernel $FiSystem
              if ( $Fikernel -eq  $Fw.dn ) 
              { 
             # Write-Host "made it to the kernel"
              $Fi.Kernel = $Fw.version 
              }
              if ( $FiSystem -eq $Fw.dn )
              { 
             # Write-Host "made it to the system"
              $Fi.System = $Fw.version 
               }
           }
           #Write-Host "end Results" $Fi.id $Fi.Kernel $Fi.System 
           } 
    return $FiData | Sort-Object id
}

function BuildUCSFIInfo ($sheet, $ClvArray, $ClfArray ) {
 Write-Host "Building UCS Cluster area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Name",
      "IP Address",
      "Username",
      "Password",
      "UCSM Version")      
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series Cluster Information" $row $col
 ### Details/Data
   $row += 1 
  
    foreach ( $sp in $ClvArray )
      { 
      #Write-Host "Cluster stuff" $sp.dn $sp.name $sp.IP $sp.Firm 
      $UCSClusterNAme =$sp.name 
      $sheet.Cells.Item($row, $startcol)    = $sp.name
      if ( $ucsClusterIP -eq $sp.IP )
      { $sheet.Cells.Item($row, $startcol+1)  = $sp.IP }
      else 
      { $sheet.Cells.Item($row, $startcol+1)  = $sp.IP +"NATed($ucsClusterIP)" }
      $sheet.Cells.Item($row, $startcol+2)  = $Uname
      $sheet.Cells.Item($row, $startcol+3)  = $Pword
      $sheet.Cells.Item($row, $startcol+4)  = $sp.Firm
      $row += 1
      }
    $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
  
     $startrow = $row
     $startcol = $col
  
    $colHeaders = @(
      "Fabric Name",
      "Fabric IP Address",
      "Model",
      "Serial",
      "NXOS System",
      "NXOS Kickstart")
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series Fabric Interface Information" $row $col

   ### Details/Data
   $row += 1
      
      foreach ( $sp in $Clfarray )
         {
         Write-Host "." -NoNewLine 
         #  Write-Host $sp.dn $sp.id $sp.name $sp.serial $sp.model $sp.IP $sp.Kernel $sp.system 
         $sheet.Cells.Item($row, $startcol)    = $UCSClusterNAme+"-"+$sp.id
         $sheet.Cells.Item($row, $startcol+1)  = $sp.IP
         $sheet.Cells.Item($row, $startcol+2)  = $sp.model
         $sheet.Cells.Item($row, $startcol+3)  = $sp.serial
         $sheet.Cells.Item($row, $startcol+4)  = $sp.system
         $sheet.Cells.Item($row, $startcol+5)  = $sp.Kernel
         $row += 1
       }  
   $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
 Write-Host "."
$row, $col 
}

function getUCSChassis ($url, $inCookie) {
# some data
    Write-Host "Retrieving UCS Chassis Details ..."
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='equipmentChassis'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        $ucs = New-Object object
        #Write-Host $sp.dn $sp.id $sp.model $sp.serial $sp.adminState
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty id $sp.id
        $ucs | Add-Member NoteProperty model $sp.model
        $ucs | Add-Member NoteProperty serial $sp.serial
        $ucs | Add-Member NoteProperty state $sp.adminState
        $a += $ucs
    }
     return $a | Sort-Object @{expression={[double]$_.'id'}}
}

function BuildUCSChassis ( $sheet, $chArray ) {
   Write-Host "Building Chassis area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Chassis ID",
      "Model",
      "Serial",
      "State")      
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series Chassis Information" $row $col
 ### Details/Data
   $row += 1
   
 foreach ($ch in $chArray ) 
   {
    Write-Host "." -NoNewLine 
   #Write-Host  $ch.id $ch.serial $ch.model $ch.state
    $sheet.Cells.Item($row, $startcol)    = $ch.id
    $sheet.Cells.Item($row, $startcol+1)  = $ch.model
    $sheet.Cells.Item($row, $startcol+2)  = $ch.serial
    $sheet.Cells.Item($row, $startcol+3)  = $ch.state
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
  Write-Host "."
    $row, $col
}

function getServiceProfiles($url, $inCookie) {
    Write-Host "Retrieving UCS Service Profiles Details ..."
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='lsServer'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty name $sp.name
        $ucs | Add-Member NoteProperty pnDn $sp.pnDn
        $ucs | Add-Member NoteProperty assocState $sp.assocState
        $a += $ucs
    }
    return $a | Sort-Object name
}

function getComputeBlades($url, $inCookie) {
    Write-Host "Retrieving UCS blade Details..."
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='computeBlade'></configResolveClass>"
    $xml = ucsPost $url $myinput
    #Write-Host "im in the blade loop"
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty serial $sp.serial
        $ucs | Add-Member NoteProperty serverID $sp.serverID
        $ucs | Add-Member NoteProperty model $sp.model
        $ucs | Add-Member NoteProperty name $sp.name
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty Memory $sp.totalMemory
        $ucs | Add-Member NoteProperty Adaptors $sp.numOfAdaptors
        $ucs | Add-Member NoteProperty Cores $sp.NumOfCores
        $ucs | Add-Member NoteProperty uuid $sp.uuid
        # while here make some blank data sets for Service-Profile Associations later
        $ucs | Add-Member NoteProperty spassocState  ""
        $ucs | Add-Member NoteProperty spname   ""
        $a += $ucs
    }
        
    return $a | Sort-Object serverID
}

function BuildComputeBlades( $sheet, $BlArray, $spArray ) {
    Write-Host "Building Blade area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col
   # set these for now, might use later with a rvtool grab or a powercli to vcenter
      $ESXHostname = ""
      $ESXLogin = ""
      $ESXPassword = ""
      $ESXBaseOS = ""
      $ESXClusterMember = ""
   
   $colHeaders = @(
      "Chassis/Slot",
      "Model",
      "Serial Number",
      "Memory",
      "Adapter(s)",
      "State",
      "Service Profile",
      "UUID (Used to tie data to vCenter and N1k)",
      "ESX Hostname",
      "ESX Login ID",
      "ESX Login PW",
      "ESX Base OS",
      "ESX Cluster Member")      
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series Blade Server Information" $row $col
 ### Details/Data
   $row += 1
   
   foreach ($bl in $BlArray) 
           {
           #Loop thru the blades and then search for the coorsponding Service Profile 
           foreach ($sp in $spArray ) 
              {
              if ( $sp.pnDn -eq $bl.dn )
                 {
                 $bl.spassocState = $sp.assocState
                 $bl.spname =  $sp.name   
                 }
               else 
                 {       
              }
          }
		 Write-Host "." -NoNewLine 
         # Write-Host  $bl.serverID $bl.serial $bl.model $bl.name $bl.Memory $bl.Cores $bl.Adaptors $bl.spassocState $bl.spname
            $sheet.Cells.Item($row, $startcol)    = "'" + $bl.serverID
            $sheet.Cells.Item($row, $startcol+1)  = $bl.model
            $sheet.Cells.Item($row, $startcol+2)  = $bl.Serial
            $sheet.Cells.Item($row, $startcol+3)  = $bl.Memory
            $sheet.Cells.Item($row, $startcol+4)  = $bl.Adaptors
            $sheet.Cells.Item($row, $startcol+5)  = $bl.spassocState
            $sheet.Cells.Item($row, $startcol+6)  = $bl.spname
            $sheet.Cells.Item($row, $startcol+7)  = $bl.uuid 
            $sheet.Cells.Item($row, $startcol+8)  = $ESXHostname
            $sheet.Cells.Item($row, $startcol+9)  = $ESXLogin
            $sheet.Cells.Item($row, $startcol+10) = $ESXPassword
            $sheet.Cells.Item($row, $startcol+11) = $ESXBaseOS
            $sheet.Cells.Item($row, $startcol+12) = $ESXClusterMember

            $row += 1

         }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
  Write-Host "."
    $row, $col
}

function getUCSVlanData ($url, $inCookie) {
    Write-Host "Retrieving UCS VLAN Details ..." 
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='fabricVlan'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty name $sp.name
        $ucs | Add-Member NoteProperty id $sp.id
        $ucs | Add-Member NoteProperty ifRole $sp.ifRole
        $ucs | Add-Member NoteProperty switchId $sp.switchId
        $a += $ucs
    }
     return $a | Sort-Object @{expression={[double]$_.'id'}}
}

function BuildUCSVlanData ( $sheet, $VlArray ) {
   Write-Host "Building Vlan area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Vlan ID",
      "Vlan Name",
      "Fabric Member",
      "Vlan Role")      
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series VLAN Information" $row $col
   ### Details/Data
   $row += 1

   foreach ($vl in $VlArray ) 
    {
     Write-Host "." -NoNewLine 
    #Write-Host "vlan" $vl.id "Name" $vl.name "Fabric member" $vl.SwitchId "Vlan Role" $vl.ifRole 
    $sheet.Cells.Item($row, $startcol)    = $vl.id
    $sheet.Cells.Item($row, $startcol+1)  = $vl.name
    $sheet.Cells.Item($row, $startcol+2)  = $vl.SwitchId
    $sheet.Cells.Item($row, $startcol+3)  = $vl.ifRole
    $row += 1
    }
    $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
   Write-Host "."
    $row, $col
}

function getUCSVsanData ($url, $inCookie) {
    Write-Host "Retrieving UCS VSAN Details ..."
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='fabricVsan'></configResolveClass>"
    $xml = ucsPost $url $myinput
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty dn $sp.dn
        $ucs | Add-Member NoteProperty name $sp.name
        $ucs | Add-Member NoteProperty id $sp.id
        $ucs | Add-Member NoteProperty ifRole $sp.ifRole
        $ucs | Add-Member NoteProperty fcoeVlan $sp.fcoeVlan
        $ucs | Add-Member NoteProperty switchId $sp.switchId
        $a += $ucs
    }
    return $a | Sort-Object @{expression={[double]$_.'id'}}
}

function BuildUCSVsanData ( $sheet, $VlArray ) {
   Write-Host "Building Vsan area..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "VSan ID",
      "VSan Name",
      "Fabric Member",
      "Vlan Role",
      "FcOE VLAN")      
 
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS B-Series VSAN Information" $row $col
   ### Details/Data
   $row += 1

   foreach ($vs in $VsArray ) 
  {
     Write-Host "." -NoNewLine 
 	# Write-Host "vsan" $vs.id "Name" $vs.name "Fabric member" $vs.SwitchId "Vsan Role" $vs.ifRole "FcOE Vlan" $vs.fcoeVlan
    $sheet.Cells.Item($row, $startcol)    = $vs.id
    $sheet.Cells.Item($row, $startcol+1)  = $vs.name
    $sheet.Cells.Item($row, $startcol+2)  = $vs.SwitchId
    $sheet.Cells.Item($row, $startcol+3)  = $vs.ifRole
    $sheet.Cells.Item($row, $startcol+4)  = $vs.fcoeVlan  
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


### setup some basic variables if need be
###

if ($Readin) 
{ 
  
if ( Test-Path $url )
 {
 Write-Host "Found the file, Now reading."
 Write-Host ""
   $AllTheData = Import-Clixml $url 
 Write-Host "reconstituing data"
   
 $ClvArray ,$Clfarray ,  $licArray , $chArray , $spArray , $BlArray, $VlArray, $VsArray, $EthArray, $FcArray = $AllTheData
       foreach ( $sp in $ClvArray )
      { 
      $ucsClusterIP  = $sp.IP
      }
     $Uname = "Offline Build"
     $Pword = "Offline Build"
 } else { 
      Write-Host "file specified not found"
   break }
 
   }
  else {
# now go build the data

if (($url) -and ($url -as [ipaddress])){
    $global:ssl = $ssl 
    $ucsCreds = Get-Credential admin
    if ($ucsCreds) 
    {
        $user = $ucsCreds.Username.substring(1)
		$cookie = ucsLogin $url $user $ucsCreds.GetNetworkCredential().password 
        }
   else {"Please provide a valid UCSM IP and Password"}
   }

 if (!$cookie) { 
 Write-Host "Could not login validate reachability or Creds."
 break}
       # grab the data.
        $licArray = getUCSLicenseData  $url $cookie 
        $ClvArray = getUCSCClusterInfo $url $cookie
        $Clfarray = getUCSFIInfo       $url $cookie
        $chArray  = getUCSChassis      $url $cookie
        $spArray  = getServiceProfiles $url $cookie
        $BlArray  = getComputeBlades   $url $cookie 
 		$VlArray  = getUCSVlanData     $url $cookie
 		$VsArray  = getUCSVsanData     $url $cookie 
 		$EthArray = getUCSEtherData    $url $cookie 
        $FcArray  = getUCSFcData       $url $cookie

# need to set these from what was entered to put into the CRG output
     $ucsClusterIP  = $url 
     $Uname = $ucsCreds.GetNetworkCredential().Username
     $Pword = $ucsCreds.GetNetworkCredential().Password
  
   Write-Host "Logging out of UCSM"
   $status = ucsLogout $url $cookie
   if ($status -eq "success") {
       Write-Host "Logout Successful."
       } else {
       Write-Host "Error logging out."
       }
}
### 


Write-Host "Creating Excel COM Object... "
$erroractionpreference = "SilentlyContinue"
$excel         = New-Object -ComObject Excel.Application
$excel.visible = $false
################ Save the file 
if ($Write) { 
# get cluster name for fileto save as
foreach ( $sp in $ClvArray )
      { 
      $UCSClusterNAme =$sp.name 
      }
      $outfile = $UCSClusterNAme + ".data"

Write-Host "saving data as" $outfile
    
 $AllTheData = @(
        $ClvArray ,
        $Clfarray ,
        $licArray , 
        $chArray  ,
        $spArray  ,
        $BlArray  , 
 		$VlArray  ,
 		$VsArray  , 
 		$EthArray , 
        $FcArray )
 $AllTheData | Export-Clixml .\$outfile
}
if ($noexcel ) { 
Write-Host "you chose no excel output, now exiting."
break }

################################ Create Array Details Worksheet ######################################
# Fire off Excel COM object
#

#
# build the Excel CRG output
Write-Host "Creating Compute Information worksheet "
$wb            = $excel.Workbooks.Add()
#
$sheet1        = $wb.Worksheets.Item(1) 
$sheet1.Name   = "Compute"
$wb.Worksheets("Compute").Activate


### start in cell B2
[int]$row = 2
[int]$col = 2
  
   $row, $col = BuildUCSFIInfo     $sheet1 $ClvArray $Clfarray
   $row, $col = BuildUCSChassis    $sheet1 $chArray
   $row, $col = BuildComputeBlades $sheet1 $BlArray $spArray
   $row, $col = BuildUCSVlanData   $sheet1 $vlArray
   $row, $col = BuildUCSVsanData   $sheet1 $vsArray
   $row, $col = BuildUCSLicense    $sheet1 $licArray
   $row, $col = BuildUCSEtherData  $sheet1 $EthArray 
   $row, $col = BuildUCSFcData     $sheet1 $FcArray 


#######################################################################################################
# # # # # # # # # # # # # # # # Display Spreadsheet # # # # # # # # # # # # # # # # # # # # # # 


Write-Host "Complete - Displaying Excel Spreadsheet (be sure to save it)"
$excel.visible = $true
Write-Host " "
Write-Host " "
# $sheet1.SaveAs("what.xlsx")
