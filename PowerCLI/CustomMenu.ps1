#
# Add Run with arguments capability
#
$psise.CustomMenu.Submenus.Clear()
$__menu__ = $psise.CustomMenu.Submenus.Add("Run Script With Arguments", $null, $null)
$__menu__.SubMenus.Add("Run", {. "$psise.CurrentOpenedFile.FullPath" $__scriptargs__}, "Ctrl+Alt+R") | Out-Null
$__menu__.SubMenus.Add("Run In New Process", {& $psise.CurrentOpenedFile.FullPath $__scriptargs__}, $null) | Out-Null
$__menu__.SubMenus.Add("Enter Arguments", {$__scriptargs__ = Read-Host "Script Arguments"}, $null) | Out-Null
$__menu__.SubMenus.Add("Show Arguments", {$__scriptargs__}, $null) | Out-Null

#
# Add snippet capability
#
Function Show-SnippetDialog
{
	param([string]$dialog,[string]$Directory, [string]$Filter="All Files (*.*)|*.*")
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") > $null
	
    if ($dialog -eq "Open")
    {
        $frmFile = New-Object System.Windows.Forms.OpenFileDialog
        $frmFile.Title = "Open Snippet"
    }
    elseif ($dialog -eq "Save")
    {
        $frmFile = New-Object System.Windows.Forms.SaveFileDialog
        $frmFile.Title = "Save Snippet"
    }
    else
    {
        throw "Invalid option: $dialog"
    }
	$frmFile.InitialDirectory = $Directory
	$frmFile.Filter = $Filter
    
    # frmTop is a hack to help ensure the dialog shows up on top of the editor
    # window.  Otherwise it tends to pop under.
    
    function Point {New-Object System.Drawing.Point $args}
    $frmTop = New-Object System.Windows.Forms.Form
    $frmTop.Size = point 1 1
    $frmTop.FormBorderStyle = "None"
    $frmTop.StartPosition = "CenterScreen"
    $frmTop.Opacity = 0.0
    $frmTop.Show()
    $frmTop.BringToFront()
    $result = $frmFile.ShowDialog($frmTop)
    $frmTop.Close()
    
	if ($result -eq "OK")
	{
		return $frmFile.FileName
	}
	else
	{
		return $null
	}
}


Function Insert-Snippet
{
    $snippet_dir = [System.Environment]::GetFolderPath("MyDocuments") + "\WindowsPowerShell\Snippets"
    
    if (-not (Resolve-Path $snippet_dir -ErrorAction SilentlyContinue)) {mkdir $snippet_dir}
    
    $filename = Show-SnippetDialog "Open" $snippet_dir
    
    if ($filename)
    {
        # Insert into current buffer
        $file_content = Get-Content $filename
        $psiSE.CurrentOpenedFile.Editor.InsertText($file_content)
    }
}

$__menu__ = $psise.CustomMenu.Submenus.Add("Snippets", $null, $null)
$__menu__.SubMenus.Add("Insert Snippet", {Insert-Snippet}, "Ctrl+Alt+i") | Out-Null


#
# Show comment notes.
#
Function Show-ActionComments()
{
    $action_re = "#\s*TODO.*|#\s*BUG.*"
    
    $lines = $psise.CurrentOpenedFile.Editor.Text.Split("`n")
    
    for ($i=1; $i -le $lines.Length; $i++)
    {
        $match = [Regex]::Match($lines[$i-1], $action_re, `
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($match.Success)
        {
            "Line {0}: {1}" -f $i, $lines[$i-1]
        }
    }
}
$__menu__ = $psise.CustomMenu.Submenus.Add("Show TODO/BUG", {Show-ActionComments}, $null)

#
# Clear the command editor window
#
$__menu__ = $psise.CustomMenu.Submenus.Add("Clear Command Editor", `
    {$psise.CurrentOpenedRunspace.CommandPane.Clear()}, "Ctrl+Alt+C")