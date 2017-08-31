$workstations = Get-Content .\pclist.txt
$datestamp = Get-Date -Format "yyyyMMdd"

foreach ($workstation in $workstations) {
    $cdviewer = "\\$workstation\C$\Program Files\Citrix\ICA Client\CDViewer.exe"

    if (Test-Path $cdviewer) {
        $citrixver = (Get-Command $cdviewer).FileVersionInfo.FileVersion
    } else {
        $citrixver = "Not Installed"
    }
    
    "$workstation | $citrixver" | Out-File -Append .\citrix_results-$datestamp.txt
}