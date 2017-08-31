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
#  1.8 Robert Auvil 28-Feb-2012 - corrected $global variiable, adjusted excel    #
#                                 com object location,added decomm chassis, and  #
#                                 removed unused interfaces from Eth wiremap     #
#  NOTE Version is just below the input param box.                               #
#  1.9 Robert Auvil 11-Mar-2012 - refering to crg_globalfunc.ps1, added ver up
#                               - top, added VBID variable, added autosave feature
#                               - reformatted date function for data,cfg files   # 
#                               - removed sheet2 and sheet 3
#  1.10 Robert Auvil 19-Mar-2012- modifyed user input method.                    #
#  1.11 Robert Auvil 29-Mar-2012- removed WMI login prompt for credentials
# 								- to help with batch mode processing             #
#  1.12 Robert Auvil 13-Jul-2012 - removed ESX stuff. Julian built a CRG collector
#                                - Added CPU/Cores
##################################################################################


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
   $nossl,
   [switch]
   $noexcel,
   [switch]
   $noWrite,
   [switch]
   $Readin,
   [switch]
   $Batch
)
$myver="UCS Ver1.12"
$myFileDate    = Get-Date -format yyyyMMdd_HH_mm
. .\crg_globalfunc.ps1

### here is the stuff for xmlapi

function ucsPost($url,$data) {
    if ($script:nossl){
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
    if (!$x.ifRole.contains("unknown")) {
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
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='fabricSwChPhEp'></configResolveClass>"
    $xml = ucsPost $url $myinput
    #$a = @()
    $myid =""
    foreach ($sp in $xml.configResolveClass.outConfigs.childnodes) {
        if ( $sp.lc.contains("out-of-service") ) {
        $ucs = New-Object object
        #Write-Host $sp.dn $sp.id $sp.model $sp.serial $sp.adminState
        $ucs | Add-Member NoteProperty dn $sp.epdn
        $ucs | Add-Member NoteProperty id ($sp.epdn -split '-')[1]
        $ucs | Add-Member NoteProperty model $sp.model
        $ucs | Add-Member NoteProperty serial $sp.serial
        $ucs | Add-Member NoteProperty state "Decomissioned"
        $a += $ucs
        }
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
        $ucs | Add-Member NoteProperty CPUS $sp.NumOfCpus
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
	  "CPU/Cores",
      "Memory",
      "Adapter(s)",
      "State",
      "Service Profile",
      "UUID (Used to tie data to vCenter and N1k)")      
      

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
            $sheet.Cells.Item($row, $startcol+3)  = "``" + $bl.CPUS + "/" + $bl.Cores
            $sheet.Cells.Item($row, $startcol+4)  = $bl.Memory
            $sheet.Cells.Item($row, $startcol+5)  = $bl.Adaptors
            $sheet.Cells.Item($row, $startcol+6)  = $bl.spassocState
            $sheet.Cells.Item($row, $startcol+7)  = $bl.spname
            $sheet.Cells.Item($row, $startcol+8)  = $bl.uuid 
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

if ($Batch ) {
 Write-Host "batch mode, ignorning interactive input"}
 else {
  $Uname = "admin"
  $Pword = "V1rtu@1c3!"
  $TYPEA = "UCSM"

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


$url = $DevIPA


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
    $script:ssl = $ssl 
    if ($Pword) 
    {
  	$cookie = ucsLogin $url $Uname $Pword 
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
  
   Write-Host "Logging out of UCSM"
   $status = ucsLogout $url $cookie
   if ($status -eq "success") {
       Write-Host "Logout Successful."
       } else {
       Write-Host "Error logging out."
       }
}
### 


################ Save the file 
if (!$noWrite) { 
# get cluster name for fileto save as
foreach ( $sp in $ClvArray )
      { 
      $UCSClusterNAme =$sp.name 
      }
      $outfile = $VBID + "_" + $UCSClusterNAme + "_" + $myFileDate  + ".data"

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
Write-Host "Creating Excel COM Object... "
$erroractionpreference = "SilentlyContinue"
$excel         = New-Object -ComObject Excel.Application
$excel.visible = $false

#
# build the Excel CRG output
Write-Host "Creating Compute Information worksheet "
$wb            = $excel.Workbooks.Add()
#
$sheet1        = $wb.Worksheets.Item(1) 
$sheet1.Name   = "Compute"
$wb.Worksheets("Compute").Activate

$sheet1.Cells.Item(1,1) = $myver
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
# $sheet1.SaveAs("what.xlsx")
$myWkBk        = "$VBID`_UCS-B-Series`_$myFileDate`_CRG.xlsx"
$wb.SaveAs("$pwd`\$myWkBk")
