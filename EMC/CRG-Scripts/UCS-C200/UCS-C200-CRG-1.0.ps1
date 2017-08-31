##################################################################################
#                                                                                #
# UCS C200 report tool                                                           #
# This script is intended to be used for creating the CRG document to hand over  #
#   to the customer for final documentation.                                     #
#   ver .2 5-April-2012 first build                                              #
##################################################################################

param
(
   [parameter(Mandatory = $false)][string] $VBID   ,
   [parameter(Mandatory = $false)][string] $DevIPA ,
   [parameter(Mandatory = $false)][string] $DevIPB ,
   [parameter(Mandatory = $false)][string] $Uname  ,
   [parameter(Mandatory = $false)][string] $Pword  ,
   [switch] $nossl,
   [switch] $noexcel,
   [switch] $noWrite,
   [switch] $Readin,
   [switch] $Batch
)
$myver="UCS C200 Ver.2"
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
    $request.UserAgent = "lwp-request/2.06"
    $request.ContentType = "application/x-www-form-urlencoded"
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


function getUCS ($url, $inCookie) {
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='computeRackUnit'/>"
    $xml = ucsPost $url $myinput
   # Write-Host $xml.    
   #Write-Host "x" $xml.configResolveClass.outConfigs.computeRackUnit.serial
    $a = @()
    foreach ($sp in $xml.configResolveClass.outConfigs.computeRackUnit) {
        $ucs = New-Object object
        $ucs | Add-Member NoteProperty model $sp.model
        $ucs | Add-Member NoteProperty ServerId $sp.ServerId
        $ucs | Add-Member NoteProperty serial $sp.serial
        $ucs | Add-Member NoteProperty totalMemory $sp.totalMemory
        $ucs | Add-Member NoteProperty numOfCpus $sp.numOfCpus
        $ucs | Add-Member NoteProperty numOfCores $sp.numOfCores
        $ucs | Add-Member NoteProperty uuid $sp.uuid
        }
     
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='mgmtIf'/>"
    $xml = ucsPost $url $myinput
     $ucs | Add-Member NoteProperty extIp $xml.configResolveClass.outConfigs.mgmtIf.extIp
     $ucs | Add-Member NoteProperty name $xml.configResolveClass.outConfigs.mgmtIf.name
     Write-Host "ip is" $xml.configResolveClass.outConfigs.mgmtIf.extIp
    $myinput = "<configResolveClass cookie='" + $inCookie + "' inHierarchical='false' classId='firmwareRunning'/>"
    $xml = ucsPost $url $myinput
    foreach ($sp in $xml.configResolveclass.outConfigs.firmwareRunning) {
       if ( $sp.deployment.contains("system") -and  $sp.type.contains("blade-controller") ) {
        #Write-Host $sp.dn $sp.id $sp.model $sp.serial $sp.adminState
        $ucs | Add-Member NoteProperty deployement $sp.deployment
        $ucs | Add-Member NoteProperty type $sp.type
        $ucs | Add-Member NoteProperty version $sp.version
        }
                }
     return $ucs
}

function BuildUCS ($sheet, $C200DNTree ) {
 Write-Host "Building UCS C200 area ..." -NoNewline
   [int]$startrow = $row
   [int]$startcol = $col

   $colHeaders = @(
      "Name",
      "IP Address",
      "Username",
      "Password",
      "Model",
      "Serial",
      "UCS C200 Version",
      "CPU/Core",
      "Total Memory",
      "uuid")      
      

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "UCS C200-Amp information" $row $col
 ### Details/Data
   $row += 1 
  
    foreach ( $sp in $C200DNTree )
    { 
      if ($sp.name -like "ucs-c2xx-m2" ) {
      $mange  = $sheet.Range($sheet.Cells.Item($row, $startcol), $sheet.Cells.Item($row,$startcol)) 
      $mange.Interior.Color      = $Yellow
      $mange.HorizontalAlignment = 3
      $mange.Font.Bold           = $true
      $sheet.Cells.Item($row, $startcol)  = $sp.name }
      else {
      $sheet.Cells.Item($row, $startcol)  = $sp.name
      } 
      $sheet.Cells.Item($row, $startcol+1)  = $sp.extIp
      $sheet.Cells.Item($row, $startcol+2)  = $Uname
      $sheet.Cells.Item($row, $startcol+3)  = $Pword
      $sheet.Cells.Item($row, $startcol+4)  = $sp.model
      $sheet.Cells.Item($row, $startcol+5)  = $sp.serial
      $sheet.Cells.Item($row, $startcol+6)  = $sp.version
      $sheet.Cells.Item($row, $startcol+7)  = "'"+ $sp.numOfCpus + "/" + $sp.numOfCores 
      $sheet.Cells.Item($row, $startcol+8)  = $sp.totalMemory
      $sheet.Cells.Item($row, $startcol+9)  = $sp.uuid
      $row += 1
       }
    $row -= 1
    drawBox $sheet $range $startrow $startcol $newcol $offset $row $col
    $row += 2
  
 Write-Host "."
$row, $col 
}

if ($Batch ) {
 Write-Host "batch mode, ignorning interactive input"}
 else {
  $Uname = "admin"
  $Pword = "V1rtu@1c3!"
  $TYPEA = "UCSC200"

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
    if ($HA ) {
      $DevIPA = Read-Host "Enter the IP address for $TYPEA A" 
      $DevIPB = Read-Host "Enter the IP address for $TYPEA B" 
     } else {
      $DevIPA = Read-Host "Enter the IP address for $TYPEA A" 
      }
    }
   }
  Write-Host " "
  Write-Host "VBLOCK ID is set to: $VBID"
   if ($readin ) {
     Write-Host "Stored data file name is set to: $DevIPA"
     }
     else {
      if ($HA ) {
     Write-Host "IP address for $TYPEA A is set to: $DevIPA"
     Write-Host "IP address for $TYPEA B is set to: $DevIPB"
      } else {
     Write-Host "IP address for $TYPEA is set to: $DevIPA"
     }
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
  if ($HA ) {
      $DevIPA = Read-Host "Enter the IP address for $TYPEA A" 
      $DevIPB = Read-Host "Enter the IP address for $TYPEA B" 
     } else {
      $DevIPA = Read-Host "Enter the IP address for $TYPEA A" 
      }
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
      if ($HA ) {
     Write-Host "IP address for $TYPEA A is set to: $DevIPA"
     Write-Host "IP address for $TYPEA B is set to: $DevIPB"
     } else {
     Write-Host "IP address for $TYPEA is set to: $DevIPA"
     }
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
$DataFile = $DevIPA

if ($Readin) 
{ 
 if ( Test-Path $DataFile )
 {
 Write-Host "Found the file, Now reading."
 Write-Host ""
   $C200DNTree = Import-Clixml $DataFile 
 Write-Host "reconstituing data"
   
     $ucsClusterIP  = $AllTheData.extIp
     $Uname = "Offline Build"
     $Pword = "Offline Build"
 } else { 
      Write-Host "file specified not found"
   break }
   }
  else {
# go get the data 
if ($DevIPA -and $DevIPB) {$C200DNTree =@() }
foreach ($url in $DevIPA, $DevIPB) {
if (($url) -and ($url -as [ipaddress])){
    $global:nossl = $nossl 
    if ($Uname -and $Pword -and $url ) 
    {
  	$cookie = ucsLogin $url $Uname $Pword
    $C200Return = getUCS $url $cookie
    }
   else {"Please provide a valid UCSC200 IP, Username, and Password"}
   }
   Write-Host "Logging out of UCSM"
   $status = ucsLogout $url $cookie
   if ($status -eq "success") {
       write-host "Done!"
       } else {
       Write-Host "Error logging out."
       }
 $C200DNTree += $C200Return
 }
}

################ Save the file 
if (!$noWrite) { 
    $outfile = $VBID + "_" + $C200DNTree.name + "_" + $myFileDate  + ".data"
    Write-Host "saving data as" $outfile
    $C200DNTree | Export-Clixml .\$outfile
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
$excel.visible = $true

#
# build the Excel CRG output
Write-Host "Creating Compute Information worksheet "
$wb            = $excel.Workbooks.Add()
#
$sheet1        = $wb.Worksheets.Item(1) 
$sheet1.Name   = "AMP C200"
$wb.Worksheets("AMP C200").Activate

$sheet1.Cells.Item(1,1) = $myver
### start in cell B2
[int]$row = 2
[int]$col = 2
  
   $row, $col = BuildUCS     $sheet1 $C200DNTree

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
$myWkBk        = "$VBID`_UCS`_$myFileDate`_CRG.xlsx"
$wb.SaveAs("$pwd`\$myWkBk")
