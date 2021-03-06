# ==============================================================================================
# 
# 
# NAME: vMAX_CRG.ps1
# 
# AUTHOR: Kevin Clark , VCE
# DATE  : 10/09/2011
# 
# COMMENT: The report script is intended to be used for creating the CRG document to hand over
#  to the customer for final documentation. This script requires the symapi_db.bin and the ACLX database backup.
# Script Requirements:
#	1. Powershell - installed by default in Windows 7, must download version 2 for xp.
# 	2. symapi_db.bin file from the array mgmt server.
# 	3. backup of the symaccess database. 
# 
# Steps to run the script.
#	1. On the array mgmt server, run symcfg discover (to update the symapi database)
#	2. Backup the symmask/access database. from a commandprompt on the array mgmt server (symaccess -sid <symid> backup -f <customer>_aclx.db
#	3.copy the symapi_db.bin file and aclx db file to your local pc.
#	4.run vMax_CRG.exe file, it will prompt to select symapi_db.bin file first, then select aclx db file.
#	5. will create CRG report, save excel file and update missing information.
# ==============================================================================================
#  Version Update:
#  1.0 Kevin Clark 10/09/2011 _ Script created
#  1.5 Kevin Clark 11/09/2011 _ updated excel format
#  2.0 Kevin Clark 12/23/2011 _ added Fast VP, changed Excel Format, Added ACXL db to get host wwpn.
#  2.1 Kevin CLark 01/17/2011 _ updated with GUI prompt for user input
################################################################################
#
Function Format-cell ()
{
   param($ws,$startrow,$startcol,$row,$endcol)
$row = $row -1
$endcol = $endcol -1

   $range = $ws.Range($ws.Cells.Item($startrow, $startcol), $ws.Cells.Item($row,$endcol))
   $range.Font.Name           = "Calibri"
   $range.Font.Size           = 8
   foreach($edge in $xlGrid)
        {
      $range.Borders.Item($edge).LineStyle  = $xlContinuous
      $range.Borders.Item($edge).Weight     = $xlThin
      $range.Borders.Item($edge).ColorIndex = 1
         }
$range.EntireColumn.AutoFit() | Out-Null
$row = $row +1
$row,$col
}
Function Get-ColHeaders ()
{
Param ($ws,$row,$col,$SectionTitle,$ColHeaders)
if ($SectionTitle -eq "none")
{
$lencolhead = $colHeaders.length-1
$endcol = $col+$lencolhead
}
else
{
$ws.Cells.Item($startrow,$startcol) = $SectionTitle
$lencolhead = $colHeaders.length-1
# set end column
$endcol = $col+$lencolhead
# begining row and column
$startcol = $col
$startrow = $row
   # Excel format
   $range  = $ws.Range($ws.Cells.Item($row, $col), $ws.Cells.Item($row,$endcol))
   $range.Merge($true)
   $range.Interior.Color      = $dkBlue
   $range.HorizontalAlignment = 3
   $range.Font.Bold           = $true
   $range.Font.Name           = "Calibri"
   $range.Font.Size           = 8

$row = $row+1
}
foreach ($title in $ColHeaders)
{
   
    $ws.Cells.Item($row, $col) = $title
    $col ++
}
   $range  = $ws.Range($ws.Cells.Item($row, $startcol), $ws.Cells.Item($row,$endcol))
   $range.Interior.Color      = $ltBlue
   $range.HorizontalAlignment = 3
   $range.Font.Bold           = $true
   $range.Font.Name           = "Arial"
   $range.Font.Size           = 8

$row = $row+1
$col = $startcol
$row,$col
}
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
Function Get-vb700mgmt()
{

[int]$startrow = $row
[int]$startcol = $col

$ws = $wb.Worksheets.Item(1);
$ws.name ="vB(700) Array mgmt";
$SectionTitle = "Array Management Servers";

$ColHeaders = @(
    "Server Name",
    "Role",
    "IP Address",
    "Login ID",
    "Password"
)

# write the column headings to the spreadsheet
$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders
 


#**************  Management Servers *********************
$data = @(
    " ",
    "Storage Array Mgt Srv",
    "xxx.xxx.xxx.xxx",
    "Administrator",
    "V1rtu@1c3!"
)

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    " ",
    "ESRS Gateway Server",
    "xxx.xxx.xxx.xxx",
    "Administrator",
    "V1rtu@1c3!"
)

$row,$col,$endcol = Format-Data $ws $row $col $data
 
 $data = @(
    " ",
    "ESRS Policy Mgmt",
    "xxx.xxx.xxx.xxx",
    "Administrator",
    "V1rtu@1c3!"
)

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    " ",
    "ESRS Policy Mgmt2",
    "xxx.xxx.xxx.xxx",
    "Administrator",
    "V1rtu@1c3!"
)

$row,$col,$endcol = Format-Data $ws $row $col $data

#format data and drawlines
Format-cell $ws $startrow $startcol $row $endcol
 

 
}
Function Get-Application ()

{
$row = $row +1
[int]$startrow = $row
[int]$startcol = $col


$ws = $wb.Worksheets.Item(1);
$ws.name ="vB(700) Array mgmt";
$SectionTitle = "Mgmt Application";

$ColHeaders = @(
    "Application Name",
    "User ID",
    "Password",
    "IP Address",
    "Port",
    "Version"
)

# write the column headings to the spreadsheet
$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders
 


#**************  Applications *********************
$data = @(
    "(SMC) Symmetrix Management Console",
    "smc",
    "smc",
    "xxx.xxx.xxx.xxx",
    "8443",
    ""
)

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    
    "(SPA) Symmetrix Performance Analyzer",
    "n/a",
    "n/a",
    " ",
    " ",
    " "
)

$row,$col,$endcol = Format-Data $ws $row $col $data
 
 $data = @(
    
    "Cisco Device Manager",
    "admin",
    "V1rtu@1c3!",
    "xxx.xxx.xxx.xxx",
    "",
    " "
)

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    "Cisco Fabric Manager ",
    "admin",
    "V1rtu@1c3!",
    "n/a",
    "n/a",
    " "
)

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    "PowerPath Lockbox",
    "n/a",
    "V1rtu@1c3!",
    "n/a",
    "n/a",
    " "
)

$row,$col,$endcol = Format-Data $ws $row $col $data
#format data and drawlines
$col,$row = Format-cell $ws $startrow $startcol $row $endcol
$col,$row
 }
Function Get-Array-Information ()
{
$row=$row +1
[int]$startrow = $row
[int]$startcol = $col

$ws = $wb.Worksheets.Item(1);
$SectionTitle = "Storage Array Details";
$ColHeaders = @(
    "Storage Array SN#",
    "Model",
    "Patch Level",
    "Name",
    "IP Address",
    "Login ID",
    "Password",
    "Port"
)

# write the column headings to the spreadsheet
$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders
 # Vmax Array Information
 $vmaxinfo=[xml](symcfg -v list -out xml);
 $a=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.symid 
 $b=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.product_model
 $c=$vmaxinfo.SymCLI_ML.Symmetrix.Enginuity.patch_level

$data = @(
    "hk$a",
    $b,
    $c,
    " ",
    "xxx.xxx.xxx.xxx",
    "n/a",
    "n/a",
    "n/a"
        )
        
$row,$col,$endcol = Format-Data $ws $row $col $data

# VNXe Details
$data = @(
    "",
    "VNXe (3100)",
    "",
    "",
    "xxx.xxx.xxx.xxx",
    "admin/service",
    "V1rtu@1c3!",
    "80/443"
        )
       

$row,$col,$endcol = Format-Data $ws $row $col $data


$data = @(
    "",
    "VNX (VG8-Celerra)",
    "",
    "",
    "xxx.xxx.xxx.xxx",
    "nasadmin/root",
    "nasadmin",
    "80/443"
        )

$row,$col,$endcol = Format-Data $ws $row $col $data
#format data and drawlines
$col,$row = Format-cell $ws $startrow $startcol $row $endcol
$col,$row
}
Function Get-AMP-Storage ()
{
$row=$row +1
[int]$startrow = $row
[int]$startcol = $col
$ws = $wb.Worksheets.Item(1);

$SectionTitle = "AMP Storage Details";
$ColHeaders = @(
    "Storage Array SN#",
    "Model",
    "Storage Pool Name",
    "RAID Type",
    "Used Storage (g)",
    "Free Storage (g)",
    "Total Storage (g)"
               )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

$data = @(
    "",
    "VNXe (3100)",
    " ",
    "R5 (4+1)",
    "",
    "",
    ""
        )
       

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    "",
    "VNXe (3100)",
    "",
    "Hot Spare",
    "300",
    "0",
    "300"
        )
       

$row,$col,$endcol = Format-Data $ws $row $col $data

$col,$row = Format-cell $ws $startrow $startcol $row $endcol
$col,$row



}
Function AMP_NFS_Detail ()
{
$row=$row +1
[int]$startrow = $row
[int]$startcol = $col
$ws = $wb.Worksheets.Item(1);

$SectionTitle = "AMP Export Details Details";
$ColHeaders = @(
    "Export IP Address",
    "Export Name",
    "Host Access IP",
    "Access"
               )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

$data = @(
    "xxx.xxx.xxx.xxx",
    " ",
    "xxx.xxx.xxx.xxx",
    "Read/Write/Root"
        )
       

$row,$col,$endcol = Format-Data $ws $row $col $data

$data = @(
    "xxx.xxx.xxx.xxx",
    " ",
    "xxx.xxx.xxx.xxx",
    "Read/Write/Root"
        )
       

$row,$col,$endcol = Format-Data $ws $row $col $data

$col,$row = Format-cell $ws $startrow $startcol $row $endcol
$col,$row



}
Function Get-Device-Count ()
{
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";
$row=$row +1
[int]$startrow = $row
[int]$startcol = $col


$SectionTitle = "Device Count";
$ColHeaders = @(
                 "Emulation",
                 "Configuration",
                 "Count"
                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders


# Get data from symdb XML          
 $devinv=[xml](symdev -inventory list -out XML_ATTRIBUTE);
    foreach( $devinfo in $devinv.SymCLI_ML.Symmetrix.Device)
	         {         
              $a=$devinfo.getAttribute("emulation")
              $b=$devinfo.getAttribute("configuration") 
              $c=$devinfo.getAttribute("count") 
              $data = @($a,$b,$c)
              $row,$col,$endcol = Format-Data $ws $row $col $data
             }              
$col,$row = Format-cell $ws $startrow $startcol $row $endcol
$col,$row
 }
Function Get-Disk-Group ()
{
# Get the worksheet
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

# Disk Group Details
# add a row to start the table

$row = $row +1

# Set the Start Row/Column for excel format
[int]$startrow = $row
[int]$startcol = $col

# Table Name
$SectionTitle = "Disk Group Detail";
# Table Headers
$ColHeaders = @(
                 "Disk Grp #",
                 "Disk Grp Name",
                 "# of Disk",
                 "Technology",
                 "Speed",
                 "Form Factor",
                 "Disk Size"
                )
# Format Table
$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders
# Get the data from xml
$diskgrpinfo=[xml](symdisk -dskgrp_summary list -out xml);
        
        foreach( $diskgrp in $diskgrpinfo.SymCLI_ML.Symmetrix.Disk_Group)
	           {         
              $a=$diskgrp.Disk_Group_Info.disk_group_number
              $b=$diskgrp.Disk_Group_Info.disk_group_name 
              $c=$diskgrp.Disk_Group_Info.disks_selected 
              $d=$diskgrp.Disk_Group_Info.technology
              $e=$diskgrp.Disk_Group_Info.speed
              $f=$diskgrp.Disk_Group_Info.form_factor
              $g=$diskgrp.Disk_Group_Info.rated_disk_size_gigabytes 
# Update Excel with detail
              $data = @($a,$b,$c,$d,$e,$f,$g)
              $row,$col,$endcol = Format-Data $ws $row $col $data
               }
# format table               
               
               $col,$row = Format-cell $ws $startrow $startcol $row $endcol
               $col,$row
               
               
                 
}
Function Get-Hot-Spares ()
{
# Hot Spare Count
#Get the worksheet

$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

#add a row to start the table

$row = $row +1

#Set the Start Row/Column for excel format

[int]$startrow = $row
[int]$startcol = $col

# Table Name
$SectionTitle = "Disk Hot Spares";

# Table Headers
$ColHeaders = @(
                 "DA #",
                 "Disk Grp #",
                 "Disk Grp Name",
                 "Technology",
                 "Speed",
                 "Vendor",
                 "Disk Size"
                )
# Format Table

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders
     
$diskhs=[xml](symdisk list -hot -out xml);

foreach( $disk in $diskhs.SymCLI_ML.Symmetrix.Disk)
	      {         
              $a=$disk.Disk_Info.ident
              $b=$disk.Disk_Info.interface 
              $c=$disk.Disk_Info.tid
              $d=$disk.Disk_Info.disk_group
              $e=$disk.Disk_Info.disk_group_name
              $f=$disk.Disk_Info.technology
              $g=$disk.Disk_Info.speed 
              $h=$disk.Disk_Info.vendor
              $i=$disk.Disk_Info.rated_gigabytes
# Update Excel with detail
              $data = @("$a-$b-$c",$d,$e,$g,$g,$h,$i)
              $row,$col,$endcol = Format-Data $ws $row $col $data
              
           }  
# format table               
               
               $col,$row = Format-cell $ws $startrow $startcol $row $endcol
               $col,$row
}
Function Get-FAST-Settings ()
{
# Storage vMAX Setting Details
# Worksheet to update
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

# add a row to start the table
$row = $row +1

# set the start row and column for excel formating
[int]$startrow = $row
[int]$startcol = $col

# Table Headers
$SectionTitle = "vMAX FAST Settings";
$ColHeaders = @(
                 "Move Mode",
                 "VP Data Move Mode",
                 "Min Perf Period",
                 "Workload Period",
                 "Max Simult Devmoves",
                 "Max Devmoves Per Day",
                 "VP Reloc Rate",
                 "Swap Notvisible Devs",
                 "Allow Only Swap",
                 "Pool Resv Cap"

                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

# Get vMax Storage Information from XML

 $vmaxinfo=[xml](symcfg list -out xml);
 $symid=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.symid
 $fastset=[xml](symfast list -sid $symid  -control_parms -out xml)
 $a=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.move_mode
 $b=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.vp_data_move_mode
 $c=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.min_perf_period
 $d=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.workload_period
 $e=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.max_simult_devmoves
 $f=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.max_devmoves_per_day
 $g=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.vp_reloc_rate
 $h=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.swap_notvisible_devs
 $i=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.allow_only_swap
 $j=$fastset.SymCLI_ML.Symmetrix.Control_Parameters.pool_resv_cap
 
  # format Data
 $data = @($a,$b,$c,$d,$e,$f,$g,$h,$i,$j)
 $row,$col,$endcol = Format-Data $ws $row $col $data

$col,$row = Format-cell $ws $startrow $startcol $row $endcol

$col,$row
}
Function Get-Thin-Pool ()
{
# Storage Thin Pool Details
# Worksheet to update
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

# add a row to start the table
$row = $row +1

# set the start row and column for excel formating
[int]$startrow = $row
[int]$startcol = $col

# Table Headers
$SectionTitle = "Thin Pool Details";
$ColHeaders = @(
                 "Pool Name",
                 "Pool Type",
                 "Dev Config",
                 "Technology",
                 "Total Tracks (G)",
                 "Total Used Tracks (G)",
                 "Total Enabled Tracks (G)",
                 "Total Free Tracks (G)"
                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

# Get Storage Pool Information from XML

$pool_list=[xml](symcfg list -pool -out xml);
foreach( $pool in $pool_list.SymCLI_ML.Symmetrix.DevicePool)
	{
              $a=$pool.pool_name
              $b=$pool.pool_type
              $c=$pool.dev_config
              $d=$pool.technology
              $e=$pool.total_tracks_gb
              $f=$pool.total_used_tracks_gb
              $g=$pool.total_enabled_tracks_gb
              $h=$pool.total_free_tracks_gb
              if ($a -ne "DEFAULT_POOL") 
              {
              $data = @($a,$b,$c,$d,$e,$f,$g,$h)
              $row,$col,$endcol = Format-Data $ws $row $col $data
              }
              }
$col,$row = Format-cell $ws $startrow $startcol $row $endcol
$col,$row


} 
Function Get-FASTVP-Policy ()
{
# Storage vMAX Setting Details
# Worksheet to update
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

# add a row to start the table
$row = $row +1

# set the start row and column for excel formating
[int]$startrow = $row
[int]$startcol = $col

# Table Headers
$SectionTitle = "vMAX FASTVP Policy";
$ColHeaders = @(
                 "Fast Policy Name",
                 "",,
                 "",
                 "# of Tiers",
                 "# of Storage Groups"
                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

# Get vMax Storage Information from XML

 $vmaxinfo=[xml](symcfg list -out xml);
 $symid=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.symid
 $fastpolicy=[xml](symfast list -sid $symid  -fp -v -out xml)
 $a=$fastpolicy.SymCLI_ML.Symmetrix.Fast_Policy.Policy_Info.policy_name
 $b="-"
 $c="-"
 $d=$fastpolicy.SymCLI_ML.Symmetrix.Fast_Policy.Policy_Info.num_of_tiers
 $e=$fastpolicy.SymCLI_ML.Symmetrix.Fast_Policy.Policy_Info.num_of_sg
  $data = @($a,$b,$c,$d,$e)
 $row,$col,$endcol = Format-Data $ws $row $col $data

$SectionTitle = "none";
$ColHeaders = @(
                 "Tier Name",
                 "Tier Type",
                 "% of Storage Group",
                 "Tier Protection",
                 "Tier Tech"
                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

 foreach( $tier in $fastpolicy.SymCLI_ML.Symmetrix.Fast_Policy.Tier)
 {
  $a=$tier.tier_name
  $b=$tier.tier_type
  $c=$tier.tier_max_sg_per
  $d=$tier.tier_protection
  $e=$tier.tier_tech
  $data = @($a,$b,$c,$d,$e)
$row,$col,$endcol = Format-Data $ws $row $col $data
 }
 $SectionTitle = "none";
$ColHeaders = @(
                 "Storage Grp Name",
                 "",
                 "",
                 "",
                 "Storage Grp Priority"
                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

 foreach( $storgrp in $fastpolicy.SymCLI_ML.Symmetrix.Fast_Policy.Storage_Group)
 {
  $a=$storgrp.sg_name
  $b="-"
  $c="-"
  $d="-"
  $e=$storgrp.sg_priority
  $data = @($a,$b,$c,$d,$e)
$row,$col,$endcol = Format-Data $ws $row $col $data
 }
 
 
  # format Data


$col,$row = Format-cell $ws $startrow $startcol $row $endcol

$col,$row

}
Function Get-FA-Details ()
 {
 # Worksheet to update
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

# add a row to start the table

$row = $row +1

# Set the Start Row/Column for excel format

[int]$startrow = $row
[int]$startcol = $col

# Table Name
$SectionTitle = "FA-Details";

# Table Headers
$ColHeaders = @(
                 "FA-ID",
                 "Port",
                 "FA-WWNN",
                 "FA-WWPN"
                )
# Format Table
$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

# Get XML Data 
 $fa_details=[xml](symcfg list -fa all -v -out xml_attribute);
   foreach($dir in $fa_details.SymCLI_ML.Symmetrix.Director)
     {
      $a = $dir.getAttribute("id")

      foreach($port in $dir.Port)
      {
          $b = $port.getAttribute("number")
          $c = $port.getAttribute("node_wwn")
          $d = $port.getAttribute("port_wwn")

              $ws.Cells.Item($row,$col)= $a;
              $ws.Cells.Item($row,$col+1)= $b;
              $ws.Cells.Item($row,$col+2).NumberFormat = "@";
              $ws.Cells.Item($row,$col+2).FormulaR1C1 = $c;
              $ws.Cells.Item($row,$col+3).NumberFormat = "@";
              $ws.Cells.Item($row,$col+3).FormulaR1C1 = $d
              $row++ 
        }
     }
     $col=$col+4
     $endcol = $col
     # format table               
               $col,$row = Format-cell $ws $startrow $startcol $row $endcol
     # offset for host table
     $fastartrow=$startrow
     $fastartcol=$startcol
               
               $col,$row,$fastartrow,$fastartcol
     
}
Function Get-vMAX-Setting()
{
# Storage vMAX Setting Details
# Worksheet to update
$ws = $wb.Worksheets.Item(2);
$ws.name ="vMAX Storage Details";

# add a row to start the table


# set the start row and column for excel formating
[int]$startrow = $row
[int]$startcol = $col

# Table Headers
$SectionTitle = "vMAX Settings";
$ColHeaders = @(
                 "vMAX SN#",
                 "IP Address",
                 "Model",
                 "Enginuity Patch Level",
                 "TimeZone",
                 "# of Disks",
                 "# of Hot Spares",
                 "# of Unconfigured Disks"

                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

# Get vMax Storage Information from XML

 $vmaxinfo=[xml](symcfg -v list -out xml);
 $a=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.symid
 $b="xxx.xxx.xxx.xxx" 
 $c=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.product_model
 $d=$vmaxinfo.SymCLI_ML.Symmetrix.Enginuity.patch_level
 $e=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.timezone
 $f=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.disks
 $g=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.hot_spares
 $h=$vmaxinfo.SymCLI_ML.Symmetrix.Symm_Info.unconfigured_disks
 $i=$vmaxinfo.SymCLI_ML.Symmetrix.Flags.symm_data_encryption
 $j=$vmaxinfo.SymCLI_ML.Symmetrix.Auto_Meta.state
 $k=$vmaxinfo.SymCLI_ML.Symmetrix.Auto_Meta.min_auto_meta_size
 $l=$vmaxinfo.SymCLI_ML.Symmetrix.Auto_Meta.meta_member_size
 $m=$vmaxinfo.SymCLI_ML.Symmetrix.Auto_Meta.meta_config
 $n=$vmaxinfo.SymCLI_ML.Symmetrix.Flags.raid_5
 $o=$vmaxinfo.SymCLI_ML.Symmetrix.Flags.raid_6
 $p=$vmaxinfo.SymCLI_ML.Symmetrix.Flags.cache_partition
 
 # format Data
 $data = @($a,$b,$c,$d,$e,$f,$g,$h)
 $row,$col,$endcol = Format-Data $ws $row $col $data

# new line of data in same table
$SectionTitle = "none";
$ColHeaders = @(               
                 "Data Encryption",
                 "Auto Meta Enabled/Disabled",
                 "Min Auto Meta Size",
                 "Meta Member Size",
                 "Meta Config",
                 "Default R5",
                 "Default R6",
                 "Cache Partition"   
               )
$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders
   
   # format Data
   
   $data = @($i,$j,$k,$l,$m,$n,$o,$p)
   $row,$col,$endcol = Format-Data $ws $row $col $data
   
$col,$row = Format-cell $ws $startrow $startcol $row $endcol

$col,$row


}
Function Get-Host-Details ()
{
$ws = $wb.Worksheets.Item(2);

[int]$startrow = $fastartrow
[int]$startcol = $fastartcol+5
[int]$row=$startrow
[int]$col=$startcol
# Table Headers
$SectionTitle = "Host Details";
$ColHeaders = @(
                 "Host/Grp Name",
                 "Assigned WWPN"
                )

$row,$col = Get-ColHeaders $ws $row $col $SectionTitle $ColHeaders

$host_details=[xml](symaccess -f $dbfile list view -v -out xml);
   foreach($host1 in $host_details.SymCLI_ML.Backup.Masking_View)
   {
   $a=$host1.View_Info.view_name
   $servername = $a.tostring().split("_")
   $ws.Cells.Item($row,$col)=$servername[1];
   $b=$servername[1]
   $wwn = [xml] (symaccess -f $dbfile show $a view -out xml) 
     foreach ($wwpn in $wwn.SymCLI_ML.Backup.Masking_View.View_Info.Initiators.group_name) 
   {
 $c=$wwpn
 $data = @($b,$c)
 $row,$col,$endcol = Format-Data $ws $row $col $data
    }
    }
$col,$row = Format-cell $ws $startrow $startcol $row $endcol

$col,$row
}
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
	{
		Return $objForm.FileName
	}
	Else
	{
		Write-Error "Operation cancelled by user."
	}
}


# *** Entry Point to Script ***



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

#select symapi database
Write-Host "Enter SYMAPI DB FILE"
$symapi_db = Select-FileDialog -Title "Select a SYMAPI_DB" -Directory "c:\temp" -Filter "symapidb(*.bin)|*.bin"

$env:SYMCLI_DB_FILE=$symapi_db
Write-Host "Enter SYMMASK DB FILE"
#$dbfile="c:\temp\symaclx_db"

$dbfile = Select-FileDialog -Title "Select a ACLX_DB" -Directory "c:\temp" -Filter "symmask db(*.db)|*.db"

#excel com object
$xl = New-Object -comobject excel.application

#excel visible during script run
$xl.Visible = $false

#excel workbook add
$wb = $xl.Workbooks.Add()

#set excel start row and colum

$row = 2
$col = 2

Write-Host ("Updating Array Mgmt Details")
$row,$col=Get-vb700mgmt
Write-Host ("Updating Application Section")
$row,$col=Get-Application
Write-Host ("Updating Storage Array Section")
$row,$col=Get-Array-Information
Write-Host ("Updating AMP Section")
$row,$col=Get-AMP-Storage
$row,$col=AMP_NFS_Detail
# Sheet (2) vMAX Storage Details
Write-Host ("Updating Sheet 2 (vMax Storage Detail)")
# Set Row and Column for Sheet 2
$row=2
$col=2
$row,$col=Get-vMAX-Setting
Write-Host ("Updating Fast Control Section")
$row,$col=Get-FAST-Settings
Write-Host ("Updating Fast Policy")
$row,$col=Get-FASTVP-Policy
Write-Host ("Updating Thin Pool Section")
$row,$col=Get-Thin-Pool
Write-Host ("Updating Device Count Section")
$row,$col=Get-Device-Count
Write-Host ("Updating Disk Group Section")
$row,$col=Get-Disk-Group
Write-Host ("Updating Hot Spares Section")
$row,$col=Get-Hot-Spares
Write-Host ("Updating FA Section .... This will take a bit, depending on how many FA ports!")
$row,$col,$fastartrow,$fastartcol=Get-FA-Details
Write-Host ("Updating Host Details")
$row,$col=Get-Host-Details

Write-Host ("Save File")
$xl.Visible = $true
