[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

function Point {New-Object System.Drawing.Point $args}
function restore_backup($computername)
{

	$buhost = [System.Net.Dns]::GetHostName()
	$tsmdir = "C:\tsm\baclient"
	$tsmexe = "$tsmdir\dsmc.exe"
	$tsmargs = "restore -optfile=F:\Backups\$computername\$computername.opt \\$buhost\f$\Backups\$computername.aepsc.com-fullVM\*"
	
	if ($computername -eq "")
	{
		[Windows.Forms.MessageBox]::Show("Type a VM name into the text box.", "No VM name provided.")
		return
	}
	
	$btn_restore.Enabled = $false
	$sb.Text = "Restoring backup"
	
	# Restore the backup
	$ps = New-Object System.Diagnostics.ProcessStartInfo
	$ps.FileName = "cmd.exe"
	$ps.WorkingDirectory = $tsmdir
	$ps.Arguments = "/k $tsmexe $tsmargs"
	
	$p = [System.Diagnostics.Process]::Start($ps)

	# Notify the user of completion.
	$sb.Text = ""
	$btn_restore.Enabled = $true
}

#region UI Setup
# Main Form
$frm_main = New-Object Windows.Forms.Form
$frm_main.Text = "TSM VM Restoration Wrapper"
$frm_main.Size = point 300 180
$frm_main.MaximizeBox = $false
$frm_main.MinimizeBox = $false
$frm_main.FormBorderStyle = "FixedSingle"
$frm_main.StartPosition = "CenterScreen"

$sb = New-Object Windows.Forms.Label
$sb.Dock = "bottom"
$sb.FlatStyle = "popup"
$sb.BorderStyle = "fixed3d"
$sb.TextAlign = "middleleft"

# Text
$label = New-Object Windows.Forms.Label
$label.Text = "Enter the short name of the VM to restore:"
$label.Location = point 50 25
$label.Size = point 250 25
$label.Anchor = "top"

# Textbox
$inputbox = New-Object Windows.Forms.TextBox
$inputbox.Location = point 50 50
$inputbox.Size = point 200 25
$inputbox.Anchor = "top"

# Buttons
$btn_restore = New-Object Windows.Forms.Button
$btn_restore.Text = "R&estore"
$btn_restore.Location = point 70 90
$btn_restore.Anchor = "bottom,left"
$btn_restore.add_click({
	restore_backup $inputbox.Text
})

$btn_close = New-Object Windows.Forms.Button
$btn_close.Text = "C&lose"
$btn_close.Location = point 160 90
$btn_close.Anchor = "bottom,right"
$btn_close.add_click({
	$frm_main.Close()
})
#endregion

$frm_main.controls.addRange(($sb, $label, $inputbox, $btn_restore, $btn_close))
$frm_main.Add_Shown({$frm_main.Activate()})
$frm_main.ShowDialog()