##################################################################################
#                                                                                #
# MDS report tool                                                                #
# This script is intended to be used for creating the CRG document to hand over  #
#   to the customer for final documentation. To run this script requires that    #
#   you are able to ping the MDS switches.                                       #
#                                                                                #
# Changes:                                                                       #
#  v1.2                                                                          #
#    - Added functionality to automatically save the workbook as MdsCRG.xlsx     #
#  v1.3                                                                          #
#    - Report now sorts zones.                                                   #
#  v1.4                                                                          #
#    - Included version identification on first page.                            #
#  v1.5                                                                          #
#    - Fixed a problem with v1.4. Code was not tested before posting.            #
#                                                                                #
$myMdsVer = "MDS v1.5"
#                                                                                #
##################################################################################

Function get-MdsInfo
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
   $colHeaders = @(
      "Serial No.",
      "Model",
      "Switch Name",
      "SW Version",
      "IP Address",
      "Username",
      "Password",
      "npiv",
      "tacacs",
      "interop mode",
      "scheduler")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "MDS Information" $row $col

   ### Details/Data
   $row += 1


   $MdsIPs=$swaIP,$swbIP
   foreach($MdsIP in $MdsIPs) {
     if ($MdsIP -eq $swaIP)
     { $mdsName = $mdsAName }
     else
     { $mdsName = $mdsBName }
     
     Write-Host " "
     Write-Host "Processing switch $mdsName"
     $mdsSerialStr       = (plink -ssh -l $Uname -pw $Pword $MdsIP "show license host-id")
     # $mdsSerialStr       > $mdsName`_showlicense.txt
     $mdsSerial          = ($mdsSerialStr -split '=')[1]
     
     Write-Host "Getting switch hardware."
     $mdsHardware        = (plink -ssh -l $Uname -pw $Pword $MdsIP "show hardware")
     # $mdsHardware        > $mdsName`_showhardware.txt

     Write-Host "Determining switch model."
     $mdsModelStr        = $mdsHardware | Select-string "cisco" -Casesensitive | select-string "http" -notmatch
     $mdsModel           = ($mdsModelStr -split '\s+')[2]
     $mdsModelNum        = ($mdsModelStr -split '\s+')[3]

     Write-Host "Getting features for $mdsName"
     $mdsShowFeature     = (plink -ssh -l $Uname -pw $Pword $MdsIP "show feature")
     # $mdsShowFeature     > $mdsName`_showfeature.txt
     $mdsNpivStr         = $mdsShowFeature | Select-string "npiv"
     $mdsNpiv            = ($mdsNpivStr -split '\s+')[2]

     $mdsTacacsStr       = $mdsShowFeature | Select-string "tacacs"
     $mdsTacacs          = ($mdsTacacsStr -split '\s+')[2]

     $mdsSchedulerStr    = $mdsShowFeature | Select-string "scheduler"
     $mdsScheduler       = ($mdsSchedulerStr -split '\s+')[2]

     Write-Host "Gathering VSAN and Interop information for $mdsName"
     $mdsVsanStr         = (plink -ssh -l $Uname -pw $Pword $MdsIP "show int fc1/1 brief | grep fc")
     # $mdsVsanStr         > $mdsName`_showintfc1vsan.txt
     $mdsVsan            = ($mdsVsanStr -split '\s+')[1]

     $mdsInteropStr      = (plink -ssh -l $Uname -pw $Pword $MdsIP "show vsan $mdsVsan | grep interoperability")
     # $mdsInteropStr      > $mdsName`_showvsaninterop.txt
     $mdsInterop         = ($mdsInteropStr -split ':')[1]

     Write-Host "Getting S/W version for $mdsName"
     $mdsShowRun         = (plink -ssh -l $Uname -pw $Pword $MdsIP "show run")
     # $mdsShowRun         > $mdsName`_showrun.txt
     $mdsVersionStr      = $mdsShowRun | Select-string "version" -Casesensitive | select-string "snmp-server" -notmatch
     $mdsVersion         = ($mdsVersionStr -split '\s+')[1]

     $sheet.Cells.Item($row, $startcol)    = $mdsSerial
     $sheet.Cells.Item($row, $startcol+1)  = "$mdsModel $mdsModelNum"
     $sheet.Cells.Item($row, $startcol+2)  = $mdsName
     $sheet.Cells.Item($row, $startcol+3)  = $mdsVersion
     $sheet.Cells.Item($row, $startcol+4)  = $MdsIP
     $sheet.Cells.Item($row, $startcol+5)  = $Uname
     $sheet.Cells.Item($row, $startcol+6)  = $Pword
     $sheet.Cells.Item($row, $startcol+7)  = $mdsNpiv
     $sheet.Cells.Item($row, $startcol+8)  = $mdsTacacs
     $sheet.Cells.Item($row, $startcol+9)  = $mdsInterop
     $sheet.Cells.Item($row, $startcol+10) = $mdsScheduler
     $row += 1
   }

   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col

   $row += 2

   $row, $col

}

################################################################################
#

Function get-AIntInfo
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col

   $mdsAFlogiDa    = (plink -ssh -l $Uname -pw $Pword $swaIP "show flogi da")
   
   $colHeaders = @(
      "Interface",
      "VSAN",
      "WWPN",
      "WWNN")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "$mdsAName" $row $col

   ### Details/Data
   $row += 1

   # foreach ($fcint in get-content $mdsShowRun)
   # foreach ($fcint in $mdsShowRun)
   $mdsAFlogiDa | select-string "fc" | foreach{
     $sheet.Cells.Item($row, $startcol)   = ($_ -split '\s+')[0]
     $sheet.Cells.Item($row, $startcol+1) = ($_ -split '\s+')[1]
     $sheet.Cells.Item($row, $startcol+2) = ($_ -split '\s+')[3]
     $sheet.Cells.Item($row, $startcol+3) = ($_ -split '\s+')[4]
     $row += 1
   }

   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col

   $row += 2

   $startrow, $col

}

################################################################################
#

Function get-BIntInfo
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   # $col = 7

   $mdsBFlogiDa    = (plink -ssh -l $Uname -pw $Pword $swbIP "show flogi da")
   
   $colHeaders = @(
      "Interface",
      "VSAN",
      "WWPN",
      "WWNN")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "$mdsBName" $row $col

   ### Details/Data
   $row += 1

   # foreach ($fcint in get-content $mdsShowRun)
   # foreach ($fcint in $mdsShowRun)
   $mdsBFlogiDa | select-string "fc" | foreach{
     $sheet.Cells.Item($row, $startcol)   = ($_ -split '\s+')[0]
     $sheet.Cells.Item($row, $startcol+1) = ($_ -split '\s+')[1]
     $sheet.Cells.Item($row, $startcol+2) = ($_ -split '\s+')[3]
     $sheet.Cells.Item($row, $startcol+3) = ($_ -split '\s+')[4]
     $row += 1
   }

   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col

   $row += 2

   $row, $col

}

################################################################################
#

Function get-AZones
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col

   $mdsAZoneset    = (plink -ssh -l $Uname -pw $Pword $swaIP "show zoneset active")
   
   $colHeaders = @(
      "Zone Name",
      "VSAN")
   $myAzArray = @()

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "$mdsAName Zones" $row $col

   ### Details/Data
   $row += 1

   # foreach ($fcint in get-content $mdsShowRun)
   # foreach ($fcint in $mdsShowRun)
   $mdsAZoneset | select-string "zone name" | foreach{
     $myAzObj = New-Object System.Object
     $myAzObj | Add-Member -type NoteProperty -name zname      -value ($_ -split '\s+')[3]
     $myAzObj | Add-Member -type NoteProperty -name vsan       -value ($_ -split '\s+')[5]
     $myAzArray += $myAzObj
   }

   $myAzArray | Sort-Object zname | ForEach-Object {
     $sheet.Cells.Item($row, $startcol)   = $_.zname
     $sheet.Cells.Item($row, $startcol+1) = $_.vsan
     $row += 1
   }

   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col

   $row += 2

   $startrow, $col
}

################################################################################
#

Function get-BZones
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = 5
   $col = 5

   $mdsBZoneset    = (plink -ssh -l $Uname -pw $Pword $swbIP "show zoneset active")
   
   $colHeaders = @(
      "Zone Name",
      "VSAN")
   $myBzArray = @()

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "$mdsBName Zones" $row $col

   ### Details/Data
   $row += 1

   # foreach ($fcint in get-content $mdsShowRun)
   # foreach ($fcint in $mdsShowRun)
   $mdsBZoneset | select-string "zone name" | foreach{
     $myBzObj = New-Object System.Object
     $myBzObj | Add-Member -type NoteProperty -name zname      -value ($_ -split '\s+')[3]
     $myBzObj | Add-Member -type NoteProperty -name vsan       -value ($_ -split '\s+')[5]
     $myBzArray += $myBzObj
   }

   $myBzArray | Sort-Object zname | ForEach-Object {
     $sheet.Cells.Item($row, $startcol)   = $_.zname
     $sheet.Cells.Item($row, $startcol+1) = $_.vsan
     $row += 1
   }

   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col

   $row += 2

   $row, $col
}

################################################################################
#                                  Main                                        #
################################################################################
#
# Source common function script
#
.\crg_globalfunc.ps1
#
#  Read XML, start Excel COM Object, Parse XML, Update Excel
#
Write-Host " "
Write-Host " "
Write-Host " "

# Fire off Excel COM object
#
Write-Host "Creating Excel COM Object... "
$erroractionpreference = "SilentlyContinue"
$excel         = New-Object -ComObject Excel.Application
$excel.visible = $false
################################ Create Array Details Worksheet ######################################
Write-Host "Creating MDS Information Page "
$wb            = $excel.Workbooks.Add()
$sheet1        = $wb.Worksheets.Item(1) 
$sheet1.Name   = "MDS"
$wb.Worksheets("MDS").Activate
$sheet1.Cells.Item(1,1) = "$myMdsVer"

[int]$row = 2
[int]$col = 2
$Uname = "admin"
$Pword = "V1rtu@1c3!"

Write-Host " "
$swaIP = Read-Host "Enter the IP address for MDS-A"
$swbIP = Read-Host "Enter the IP address for MDS-B"
Write-Host " "
Write-Host "IP address for MDS-A is set to: $swaIP"
Write-Host "IP address for MDS-B is set to: $swbIP"
Write-Host " "
Write-Host "Username for MDS is: $Uname"
Write-Host "Password for MDS is: $Pword"
  Write-Host " "
$vUnameAns = Read-Host "Is this correct ([y]/n)?"

if ($vUnameAns -eq "n") {
do {
  Write-Host " "
  $Uname = Read-Host "Enter the Username for MDS:"
  $Pword = Read-Host "Enter the Password for MDS:"
  Write-Host " "
  Write-Host "You have entered $Uname for the MDS username."
  Write-Host "You have entered $Pword for the MDS password."
  Write-Host " "
  $vUnameAns = Read-Host "Are these settings correct (y/n)?"
  $vUnameAns = $vUnameAns.ToLower()
  }
until ($vUnameAns -eq "y")
}

Write-Host " "
Write-Host " "
Write-Host " "
Write-Host "Retrieving MDS Info... "
   Write-Host "Getting switch name for $swaIP"
   $mdsAName        = (plink -ssh -l $Uname -pw $Pword $swaIP "show switch")
   Write-Host "   ** Switch name for $swaIP is: $mdsAName"
   Write-Host "Getting switch name for $swbIP"
   $mdsBName        = (plink -ssh -l $Uname -pw $Pword $swbIP "show switch")
   Write-Host "   ** Switch name for $swbIP is: $mdsBName"
# Comment out next line
$row, $col = get-MdsInfo $sheet1

Write-Host "Retrieving Interface Info for $mdsAName... "
$row, $col = get-AIntInfo $sheet1

Write-Host "Retrieving Interface Info for $mdsBName... "
[int]$col = 7
$row, $col = get-BIntInfo $sheet1

################################ Create Zones Worksheet #####################################

Write-Host "Creating Zone information page... "
$sheet2      = $wb.Worksheets.Item(2)
$sheet2.Name = "MDS Zones"
$wb.Worksheets("MDS Zones").Activate

[int]$row = 2
[int]$col = 2

Write-Host "Retrieving $mdsAname zone info... "
$row, $col = get-AZones $sheet2

Write-Host "Retrieving $mdsBname zone info... "
$row, $col = get-BZones $sheet2

# # # # # # # # # # # # # # # # Display Spreadsheet # # # # # # # # # # # # # # # # # # # # # # 
Write-Host "Complete - Displaying Excel Spreadsheet (be sure to save it)"
$myFileDate    = get-date -format yyyyMMdd_HH_mm
$myWkBk        = "MDS`_$myFileDate`_CRG.xlsx"
$wb.SaveAs("$pwd`\$myWkBk")
Write-Host ""
Write-Host "******** Workbook saved as $myWkBk ********"
$excel.visible = $true
Write-Host " "
Write-Host " "
