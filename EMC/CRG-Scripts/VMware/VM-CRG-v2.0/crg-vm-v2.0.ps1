#############################################
#         Virtualization CRG                #
#      Written By:  Julian Salinas          #
#                                           #
#         Need the following:               #
#           1.) PowerShell                  #
#           2.) PowerCLI                    #
#           3.) Excel 					    #
#										    #
#										    #
#   Revision History:					    #
#	v1.1 								    #
#	- Added AMP seperation             	    #
#	- Overall Status header changed         #
#     to Status in vCenter 			        #
#   v2.0 								    #
#	- add-pssnapin VMware.VimAutomation.Core#
#	- Added Licensing Tab				    #
#	- Added Changes to Credential Prompt    #										 
#										    #
#										    #
#############################################

add-pssnapin VMware.VimAutomation.Core


###Variables defined###
$VMVersion = "Virtualization 1.0"
$vccred  = $Host.UI.PromptForCredential("The Virtual Environment Computing Company", "CRG - vCenter Credentials", "administrator", "")
$vmcred  = $Host.UI.PromptForCredential("The Virtual Environment Computing Company", "CRG - VM Credentials", "administrator", "")
$vc = Read-Host -Prompt "What is your vCenter IP Address?"

Connect-VIServer $vc -Credential $vccred

$servInst = Get-View ServiceInstance
$licMgr = Get-View $servInst.Content.licenseManager
$licAssignMgr = Get-View $licMgr.licenseAssignmentManager
 
$ErrorActionPreference = "silentlycontinue"

#region Worksheet Formatting
function Select-FileDialog
{
  param([string]$Title,[string]$Directory,[string]$Filter="All Files (*.*)|*.*")
  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
  $objForm = New-Object System.Windows.Forms.OpenFileDialog
  $objForm.InitialDirectory = $Directory
  $objForm.Filter = $Filter
  $objForm.Title = $Title
  $objForm.ShowHelp= $True
  $Show = $objForm.ShowDialog()
  $objForm.ShowHelp= $True
  If ($Show -eq "OK")
  { Return $objForm.FileName }
  Else
  { Write-Error "Operation cancelled by user." }
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
################################################################################
#
# Main formatting setup
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

#EndRegion Worksheet Formatting

#####Getting Datacenter and Cluster Information

Function get-vSphereLayout
{
	param ($sheet)
    [int]$startrow = $row
    [int]$startcol = $col
	
	$colHeaders = @(
   	  "DataCenter",
	  "Cluster Name",
	  "HA Enabled",
	  "DRS Enabled")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "vSphere Cluster Information" $row $col

	$row += 1
   
	$clusters = Get-Cluster | Sort Name
	foreach ($Cluster in $Clusters)
	{
		$i++
        $intSize = $intSize + $Cluster.Length
		
        Write-Progress -activity "Retrieving Cluster Information" -status "Percent Completed" -PercentComplete (($i / $Clusters.length)  * 100)
		
		$dname = Get-Datacenter | Select Name
		$sheet.Cells.Item($row, $startcol)    = $dname.Name
		$cname = $Cluster | Select Name, HAEnabled, DrsEnabled, DrsAutomationLevel
		$sheet.Cells.Item($row, $startcol+1)  = $cname.Name
		$sheet.Cells.Item($row, $startcol+2)  = $cname.HAEnabled
		$sheet.Cells.Item($row, $startcol+3)  = $cname.DrsEnabled
		$row += 1
     }
   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   $row += 2
   
   $row, $col
}

#####Getting AMP Hosts information

function Get-AMPinfo
{
	param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
   
   
   $colHeaders = @(
   	  "Host State in vCenter"
      "Host Name",
      "Domain Name",
	  "IP"
      "DNS",
	  "vMotion Enabled",
      "vMotion IP Address",
	  "NFS IP",
      "Version",
	  "NTP",
	  "UUID")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "vSphere AMP Information" $row $col

   ### Details/Data
   $row += 1
   $ampvmkzrow = 4
   $ampvmkorow = 4
   	
	$ampclus = Get-CLuster -Name *amp*
    $ampvmhostview = $ampclus| Get-VMHost | Get-View | sort Name
	$ampvmkview = $ampvmhostview.COnfig.Network.Vnic|where {$_.Device -eq "vmk0"}
	
   foreach($ampvmhost in $ampvmhostview) {
   	  	$i++
        $intSize = $intSize + $ampvmhost.Length
		
        Write-Progress -activity "Retrieving AMP Host Information" -status "Percent Completed" -CurrentOperation "Getting information for AMP ESXi Host" -PercentComplete (($i / $ampvmhostview.Length)  * 100)
		
   	 #grabbing vmk0 and vmk1 ##vmkz = VMK0 and vmko = VMK1
   	 $ampvmkza = $ampvmhost.Config.Network.Vnic|where {$_.Device -eq "vmk0"}
	 $ampvmkzb = foreach($ampvmkzc in $ampvmkza){$ampvmkzc.Spec.Ip.IpAddress}
	 $ampvmkoa = $ampvmhost.Config.Network.Vnic|where {$_.Device -eq "vmk2"}
	 $ampvmkob = foreach($ampvmkoc in $ampvmkoa){$ampvmkoc.Spec.Ip.IpAddress}
	 
   	 if($ampvmhost.OverallStatus.value__ -eq 3){
     $sheet.Cells.Item($row, $startcol)    = "Red"
	 $Sheet.Cells.Item($row, $startcol).Interior.ColorIndex = 3}
	 elseif($vmhost.OverallStatus.value__ -eq 2){
     $sheet.Cells.Item($row, $startcol)    = "Yellow"
	 $Sheet.Cells.Item($row, $startcol).Interior.ColorIndex = 6}
	 else{$sheet.Cells.Item($row, $startcol)    = "Green"
	 $Sheet.Cells.Item($row, $startcol).Interior.ColorIndex = 4}
	 
     $sheet.Cells.Item($row, $startcol+1)  = $ampvmhost.Config.Network.DnsConfig.HostName
	 $sheet.Cells.Item($row, $startcol+2)  = $ampvmhost.Config.Network.DnsConfig.DomainName
	 
	 foreach ($ampvmkzd in $ampvmkzb){
	 $sheet.Cells.Item($ampvmkzrow , 5)  = $ampvmkzd
	 $ampvmkzrow +=1
	 }
	 if($ampvmhost.Config.Network.DnsConfig.Address.Count -le "1"){
	 $sheet.Cells.Item($row, $startcol+4)       = [string]$ampvmhost.Config.Network.DnsConfig.Address}
	 else{$sheet.Cells.Item($row, $startcol+4)  = [string]::Join(", ",$ampvmhost.Config.Network.DnsConfig.Address)}
	 
     $sheet.Cells.Item($row, $startcol+5)       = $ampvmhost.Summary.Config.VmotionEnabled
     $sheet.Cells.Item($row, $startcol+6)       = $ampvmhost.Config.Vmotion.IpConfig.IpAddress
	
	 foreach ($ampvmkod in $ampvmkob){
	 $sheet.Cells.Item($ampvmkorow , 9)         = $ampvmkod
	 $ampvmkorow +=1
	 }
	 $sheet.Cells.Item($row, $startcol+8)       = $ampvmhost.Config.Product.FullName
	 if($ampvmhost.Config.DateTimeInfo.NtpConfig.Server.Count -le "1"){
	 $sheet.Cells.Item($row, $startcol+9)       = [string]$ampvmhost.Config.DateTimeInfo.NtpConfig.Server}
	 else{$sheet.Cells.Item($row, $startcol+9)  = [string]::Join(", ",$ampvmhost.Config.DateTimeInfo.NtpConfig.Server)}
	 $sheet.Cells.Item($row, $startcol+10)      = $ampvmhost.Hardware.SystemInfo.Uuid
	 $row += 1
     }
   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   $row += 2
   
   $row, $col
}

#####Getting AMP VM information

function get-AMPVM
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
$colHeaders = @(
      "VM Name",
      "IP Address",
      "CPU's",
      "RAM",
	  "ESXi Host",
	  "MAC Address",
	  "NIC Count",
	  "NIC Type",
	  "Port Group",
	  "Connection State",
	  "VMWare Tools Version",
	  "VMWare Tools Status",
	  "Guest OS")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "AMP VM Information" $row $col
   $row += 1
   #$col + 1
	
	$ampclus = Get-Cluster -Name *amp*
    $colvm = $ampclus | Get-VM |sort VMHost
    foreach($objvm in $colvm) {
   
     $vmnic = Get-NetworkAdapter -VM $objvm
  	 $vmview = get-VM $objvm | Get-View |sort $vmview.Guest.HostName
   	  	$i++
        $intSize = $intSize + $objvm.Length
		
        Write-Progress -activity "Retrieving AMP VM Information" -status "Percent Completed" -CurrentOperation "Getting information for AMP VM $objvm" -PercentComplete (($i / $colvm.Length)  * 100)
	
     $sheet.Cells.Item($row, $startcol)      = $vmview.Name
	 $sheet.Cells.Item($row, $startcol+1)    = [string]$vmview.Guest.IpAddress
	 $sheet.Cells.Item($row, $startcol+2)    = $objvm.NumCpu
	 $sheet.Cells.Item($row, $startcol+3)    = $objvm.MemoryMB
	 $Sheet.Cells.Item($row, $startcol+4)    = $objvm.VMHost.Name#Host.Name
	 $sheet.Cells.Item($row, $startcol+5)    = $vmnic.MacAddress
	 $Sheet.Cells.Item($row, $startcol+6)    = $vmview.Guest.Net.Count
	 $Sheet.Cells.Item($row, $startcol+7)    = [String]$vmnic.Type
	 $sheet.Cells.Item($row, $startcol+8)    = $vmnic.NetworkName
	 $sheet.Cells.Item($row, $startcol+9)    = $vmnic.ConnectionState.Connected
  	 $Sheet.Cells.Item($row, $startcol+10)   = [String]$vmview.Config.Tools.ToolsVersion
	 
	 if($vmview.Guest.ToolsStatus -eq "toolsNotInstalled"){
     $Sheet.Cells.Item($row, $startcol+11)   = [String]$vmview.Guest.ToolsStatus
     $Sheet.Cells.Item($row, $startcol+11).Interior.ColorIndex = 48

	 }
	 elseif($vmview.Guest.ToolsStatus -eq "toolsNotRunning"){
     $Sheet.Cells.Item($row, $startcol+11)   = "PoweredOff"
     $Sheet.Cells.Item($row, $startcol+11).Interior.ColorIndex = 48    
	 }
	 else{
  	 $Sheet.Cells.Item($row, $startcol+11)   = [String]$vmview.Guest.ToolsStatus
	 }   
	 $Sheet.Cells.Item($row, $startcol+12)   = $vmview.Guest.GuestFullName
	 
     
     $row += 1
	 }
	 $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   $row += 2

   $row, $col
}

#####Getting vSphere UCS Blade information

Function get-vSphereInfo
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
   
   
   $colHeaders = @(
   	  "Host State in vCenter"
      "Host Name",
      "Domain Name",
	  "IP"
      "DNS",
	  "vMotion Enabled",
      "vMotion IP Address",
	  "NFS IP",
      "Version",
	  "NTP",
	  "UUID")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "vSphere Host Information" $row $col

   ### Details/Data
   $row += 1
   $vmkzrow = 4
   $vmkorow = 4
   #$col += 1
   
   $ProdCluster = Get-Cluster | where {$_.Name -notlike "amp"}
   
    $vmhostview = $ProdCluster| Get-VMHost | Get-View | sort Name
	$vmkview = $vmhostview.COnfig.Network.Vnic|where {$_.Device -eq "vmk0"}
	
   foreach($vmhost in $vmhostview) {
   		$i++
        $intSize = $intSize + $vmhost.Length
		
        Write-Progress -activity "Retrieving UCS ESXi Host Information" -status "Percent Completed" -CurrentOperation "Getting information for UCS ESXi Hosts" -PercentComplete (($i / $vmhostview.length)  * 100)
   	 #grabbing vmk0 and vmk1 ##vmkz = VMK0 and vmko = VMK1
   	 $vmkza = $vmhost.Config.Network.Vnic|where {$_.Device -eq "vmk0"}
	 $vmkzb = foreach($vmkzc in $vmkza){$vmkzc.Spec.Ip.IpAddress}
	 $vmkoa = $vmhost.Config.Network.Vnic|where {$_.Device -eq "vmk2"}
	 $vmkob = foreach($vmkoc in $vmkoa){$vmkoc.Spec.Ip.IpAddress}
	 
   	 if($vmhost.OverallStatus.value__ -eq 3){
     $sheet.Cells.Item($row, $startcol)    = "Red"
	 $Sheet.Cells.Item($row, $startcol).Interior.ColorIndex = 3}
	 elseif($vmhost.OverallStatus.value__ -eq 2){
     $sheet.Cells.Item($row, $startcol)    = "Yellow"
	 $Sheet.Cells.Item($row, $startcol).Interior.ColorIndex = 6}
	 else{$sheet.Cells.Item($row, $startcol)    = "Green"
	 $Sheet.Cells.Item($row, $startcol).Interior.ColorIndex = 4}
     $sheet.Cells.Item($row, $startcol+1)  = $vmhost.Config.Network.DnsConfig.HostName
	 $sheet.Cells.Item($row, $startcol+2)  = $vmhost.Config.Network.DnsConfig.DomainName
	 foreach ($vmkzd in $vmkzb){
	 $sheet.Cells.Item($vmkzrow , 5)  = $vmkzd
	 $vmkzrow +=1
	 }
	 $sheet.Cells.Item($row, $startcol+4)  = [string]::Join(", ",$vmhost.Config.Network.DnsConfig.Address)
     $sheet.Cells.Item($row, $startcol+5)  = $vmhost.Summary.Config.VmotionEnabled
     $sheet.Cells.Item($row, $startcol+6)  = $vmhost.Config.Vmotion.IpConfig.IpAddress
	
	 foreach ($vmkod in $vmkob){
	 $sheet.Cells.Item($vmkorow , 9)  = $vmkod
	 $vmkorow +=1
	 }
	 $sheet.Cells.Item($row, $startcol+8)  = $vmhost.Config.Product.FullName
	 $sheet.Cells.Item($row, $startcol+9)  = [string]::Join(", ",$vmhost.Config.DateTimeInfo.NtpConfig.Server)
	 $sheet.Cells.Item($row, $startcol+10) = $vmhost.Hardware.SystemInfo.Uuid
	 $row += 1
     }
   $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   $row += 2
   
   $row, $col
}

#####Getting UCS Blade VM information - if any
$startrow = $row
function get-VMinfo
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
$colHeaders = @(
      "VM Name",
      "IP Address",
      "CPU's",
      "RAM",
	  "ESXi Host",
	  "MAC Address",
	  "NIC Count",
	  "NIC Type",
	  "Port Group",
	  "Connection State",
	  "VMWare Tools Version",
	  "VMWare Tools Status",
	  "Guest OS")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "vSphere VM Information" $row $col
   $row += 1
	
	$ProdCluster = Get-Cluster | where {$_.Name -notlike "amp"}
   $colvm = $ProdCluster| Get-VM |sort VMHost
   foreach($objvm in $colvm) {
   		$i++
        $intSize = $intSize + $objvm.Length
		
        Write-Progress -activity "Retrieving UCS ESXi VM's Information"-status "Percent Completed" -PercentComplete (($i / $colvm.length)  * 100) -CurrentOperation "Getting information for vm $objvm"
   
     $vmnic = Get-NetworkAdapter -VM $objvm
  	 $vmview = get-VM $objvm | Get-View |sort $vmview.Guest.HostName
	 
	
     $sheet.Cells.Item($row, $startcol)      = $vmview.Name
	 $sheet.Cells.Item($row, $startcol+1)    = [string]$vmview.Guest.IpAddress
	 $sheet.Cells.Item($row, $startcol+2)    = $objvm.NumCpu
	 $sheet.Cells.Item($row, $startcol+3)    = $objvm.MemoryMB
	 $Sheet.Cells.Item($row, $startcol+4)    = $objvm.VMHost.Name#.Host.Name
	 $sheet.Cells.Item($row, $startcol+5)    = $vmnic.MacAddress
	 $Sheet.Cells.Item($row, $startcol+6)    = $vmview.Guest.Net.Count
	 $Sheet.Cells.Item($row, $startcol+7)    = [String]$vmnic.Type
	 $sheet.Cells.Item($row, $startcol+8)    = $vmnic.NetworkName
	 $sheet.Cells.Item($row, $startcol+9)    = $vmnic.ConnectionState.Connected
  	 $Sheet.Cells.Item($row, $startcol+10)   = [String]$vmview.Config.Tools.ToolsVersion
	 }
	 if($vmview.Guest.ToolsStatus -eq "toolsNotInstalled"){
     $Sheet.Cells.Item($row, $startcol+11)   = [String]$vmview.Guest.ToolsStatus
     $Sheet.Cells.Item($row, $startcol+11).Interior.ColorIndex = 48
	 }
	 elseif($vmview.Guest.ToolsStatus -eq "toolsNotRunning"){
     $Sheet.Cells.Item($row, $startcol+11)   = "PoweredOff"
     $Sheet.Cells.Item($row, $startcol+11).Interior.ColorIndex = 48    
	 }
	 else{
  	 $Sheet.Cells.Item($row, $startcol+11)   = [String]$vmview.Guest.ToolsStatus
	 }   
	 $Sheet.Cells.Item($row, $startcol+12)   = $vmview.Guest.GuestFullName
	 
     
     $row += 1
	 }
	 $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   $row += 2

   $row, $col
}

###Functions for Licensing info
function Get-VMHostId($Name)
{
    $vmhost = Get-VMHost $Name | Get-View
    return $vmhost.Config.Host.Value
}

function Get-License($VMHostId)
{
    $details = @()
    $detail = "" |select LicenseKey,LicenseType,Host
    $license = $licAssignMgr.QueryAssignedLicenses($VMHostId)
    $license = $license.GetValue(0)
    $detail.LicenseKey = $license.AssignedLicense.LicenseKey
    $detail.LicenseType = $license.AssignedLicense.Name
    $detail.Host = $license.EntityDisplayName
    $details += $detail
    return $details
}

#####Getting License information

Function Build-OverallLicensevSphere{
	param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
	$colHeaders = @(
      "License Name",
      "License Key",
      "Total",
	  "Used")
	  
	
   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "vSphere Licensing" $row $col
   $row += 1
   
    $ServiceInstance = Get-View ServiceInstance

	$LicenseMan = Get-View $ServiceInstance.Content.LicenseManager
	
	Foreach ($License in $LicenseMan.Licenses){
		$i++
        $intSize = $intSize + $License.Length
		
        Write-Progress -activity "Retrieving vSphere/vCenter Licensing Keys" -status "Percent Completed" -PercentComplete (($i / $LicenseMan.length)  * 100)
	$licensedhosts = Get-VMHost
	$totalcpu = ($licensedhosts.Count *2)
	

	$Details = “”|Select Name, Key, Total, Used
	
	$sheet.Cells.Item($row, $startcol)           = $License.Name
	$sheet.Cells.Item($row, $startcol+1)         = $License.LicenseKey
	if($License.Name -eq "Product Evaluation" -and $license.Used -ge "1"){
     $Sheet.Cells.Item($row, $startcol+2).Interior.ColorIndex = 6
	 $sheet.Cells.Item($row, $startcol+2)   = $License.Total}
	 Elseif($License.Name -like "Enterprise Plus" -and $License.Used -ne $totalcpu){
	 $Sheet.Cells.Item($row, $startcol+2).Interior.ColorIndex = 6
	 $sheet.Cells.Item($row, $startcol+2)   = $License.Total}
	 Else{$sheet.Cells.Item($row, $startcol+2)   = $License.Total}
	 $sheet.Cells.Item($row, $startcol+3)         = $License.Used
	 $row +=1
	
	}
	
	 $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   
   $row += 2

   $row, $col
}

function Get-WindowsLicensing
{
param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
	$colHeaders = @(
      "VM Name",
	  "Windows OS",
      "Windows License Status")
	  
	$row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "Windows Licensing" $row $col
    $row += 1
	  
#[string]$licensed = ($slmgrResult | select-string -pattern "License Status: Licensed")
$ErrorActionPreference = "silentlycontinue"
$slmgrResult = "cscript c:\windows\system32\slmgr.vbs /dli"
$vms = Get-VM | Get-View

foreach($vm in $vms){
	$guestwin = $vm.Guest.GuestFullName
	$guestvm = $vm.Name
	if($guestwin -ceq "Microsoft Windows Server 2008 R2 (64-bit)"){
	$sheet.Cells.Item($row, $startcol)             = $guestvm}
	$sheet.Cells.Item($row, $startcol+1)           = $vm.Guest.GuestFullName
	if($guestwin -ceq "Microsoft Windows Server 2008 R2 (64-bit)"){
		#-GuestUser "administrator" -GuestPassword "V1rtu@1c3!"# 
 		Invoke-VMScript -VM $guestwin -GuestCredential $vmcred -ScriptType Bat -ScriptText $slmgrResult
		[string]$licensed = ($slmgrResult | select-string -pattern "License Status: Licensed")
		if($licensed = "License Status: Licensed"){
		$sheet.Cells.Item($row, $startcol+2)       = "Licensed"
		}
	else{$sheet.Cells.Item($row, $startcol+2)      = "Unlicensed"}
	$row +=1
	}
	
}
	$row -= 1
	drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   
	$row += 2

	$row, $col
}


#####Getting Host License information and key assigned

function Build-vSphereLicensing
{
   param ($sheet)
   [int]$startrow = $row
   [int]$startcol = $col
   
$colHeaders = @(
      "License Key",
      "License Type",
      "Host")

   $row, $col, $newcol, $range, $offset = drawHeader $sheet $colHeaders "vSphere Host Licensing" $row $col
   $row += 1
   $vmhosts = Get-VMHost | sort Name
#$details = @()
foreach ($vmhost in $vmhosts) {
		$i++
        $intSize = $intSize + $vmhost.Length
		
        Write-Progress -activity "Retrieving ESXi Licensing Information" -status "Percent Completed" -PercentComplete (($i / $vmhosts.length)  * 100) -CurrentOperation "Getting License info for $vmhost"
    $vmhostname = Get-VMHostId $vmhost.name
    $detail = Get-License $vmhostname
	$sheet.Cells.Item($row, $startcol)        = $detail.LicenseKey
	$sheet.Cells.Item($row, $startcol+1)      = $detail.LicenseType
	$sheet.Cells.Item($row, $startcol+2)      = $detail.Host
	$row += 1
	#$details += $detail
}

	 $row -= 1
   drawBox $sheet $range $startrow $startcol $newcol $offset $row $col $colHeaders
   $row += 2

   $row, $col
}


################################################################################
#                                  Main                                        #
################################################################################
#
# Source common function script
#
#. crg_globalfunc.ps1
#
#  Read XML, start Excel COM Object, Parse XML, Update Excel
#
Write-Host " "
Write-Host " "
Write-Host " "

# Fire off Excel COM object
#
Write-Host "Creating Excel COM Object... "
#$erroractionpreference = "SilentlyContinue"
$excel         = New-Object -ComObject Excel.Application
$excel.visible = $true
################################ Create Array Details Worksheet ######################################
Write-Host "Creating AMP Information Page.."
Write-Host " "
$wb            = $excel.Workbooks.Add()
$sheet1        = $wb.Worksheets.Item(1) 
$sheet1.Name   = "AMP"
$wb.Worksheets("AMP").Activate
$sheet1.Cells.Item(1,1) = $VMVersion

[int]$row = 2
[int]$col = 2
$row, $col = Get-AMPinfo $sheet1
$row, $col = Get-AMPVM $sheet1
$row, $col = get-vSphereLayout $sheet1


Write-Host "Creating VMware Information Page.."
Write-Host " "
$sheet2        = $wb.Worksheets.Item(2) 
$sheet2.Name   = "VMware"
$wb.Worksheets("VMware").Activate

[int]$row = 2
[int]$col = 2
$row, $col = get-vSphereInfo $sheet2
$row, $col = get-VMInfo $sheet2

Write-Host "Creating Licensing Information Page.."
Write-Host " "
$sheet3        = $wb.Worksheets.Item(3) 
$sheet3.Name   = "Licensing"
$wb.Worksheets("Licensing").Activate

[int]$row = 2
[int]$col = 2
$row, $col = Build-OverallLicensevSphere $sheet3
$row, $col = Build-vSphereLicensing $sheet3
$row, $col = Get-WindowsLicensing $sheet3



Write-Host "Complete - Displaying Excel Spreadsheet"
$myFileDate    = get-date -format yyyyMMdd_HH_mm
$myWkBk        = "VMware_CRG`_$myFileDate`.xlsx"
$wb.SaveAs("$pwd`\$myWkBk")
Write-Host ""
Write-Host "******** Workbook saved as $myWkBk ********"
$excel.visible = $true



Disconnect-VIServer -Server * -Force -Confirm:$false

