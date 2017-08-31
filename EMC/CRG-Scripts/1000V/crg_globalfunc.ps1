##################################################################################
#                                                                                #
# crg_globalfunc.ps1.1.                                                          #
# This script is a collection of functions used by the CRG report scripts.       #
# It is sourced by each script as needed and is intended to keep the global      #
#   functions in one spot so they can be changed once and each script will use   #
#   the same functions to keep uniformity throughout the CRG reporting process.  #
#                                                                                #
##################################################################################

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
