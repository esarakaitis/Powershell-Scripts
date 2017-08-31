function Cluster-Question
{
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
$i = 0
$form1 = New-Object System.Windows.Forms.Form
$button1 = New-Object System.Windows.Forms.Button
$button2 = New-Object System.Windows.Forms.Button
$checkBox1 = New-Object System.Windows.Forms.CheckBox
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$OnLoadForm_StateCorrection= $form1.WindowState = $InitialFormWindowState

$ClusterList = Get-Cluster | Sort Name
$Checkboxes = @()
$ClusterList | % {
    $Checkboxes += New-Object System.Windows.Forms.CheckBox
    $Checkboxes[-1].VisualStyleBackColor = $true
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 200
    $System_Drawing_Size.Height = 24
    $Checkboxes[-1].Size = $System_Drawing_Size
    $Checkboxes[-1].TabIndex = $i
    $Checkboxes[-1].text = $_
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 30
    $System_Drawing_Point.Y = 21 + $y
    $Checkboxes[-1].Location = $System_Drawing_Point
    $Checkboxes[-1].DataBindings.DefaultDataSourceUpdateMode = 0
    $Checkboxes[-1].name = "Cluster"
    $y = $y + 25
    $form1.Controls.Add($Checkboxes[-1])
}



$y = 0
$x = 0

#Submit Button
$button1.TabIndex = 1
$button1.Name = "Submit"
$button1.Location = New-Object System.Drawing.Size(15,200)
$button1.size = New-Object System.Drawing.Size(145,37)
$button1.UseVisualStyleBackColor = $True
$button1.Text = "Submit"
$checkedClus = $Checkboxes | where {$_.Checked = "True"}
$button1.add_Click({$checkedCLus
					$form1.Close()})
					

#cancel Button
$button2.TabIndex = 2
$button2.Name = "Cancel"
$button2.Location = New-Object System.Drawing.Size(170,200)
$button2.size = New-Object System.Drawing.Size(145,37)
$button2.UseVisualStyleBackColor = $True
$button2.Text = "Cancel"
$button2.Add_Click({$leave = "now" ;$form1.Close()})

$form1.Text = "VCE"
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 332
$System_Drawing_Size.Height = 285
$form1.ClientSize = $System_Drawing_Size
$form1.Controls.Add($button1)
$form1.Controls.Add($button2)
$form1.ShowDialog()| Out-Null

}
Cluster-Question
#foreach($f in $Checkedclus){
#if($checkedClus -ne $null){Write-Host $f.Text}}
#Write-Host $checkedClus
