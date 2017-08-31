$t = Get-Date
$dst = Get-VMHost | %{ Get-View $_.ExtensionData.ConfigManager.DateTimeSystem }
$dst.UpdateDateTime((Get-Date($t.ToUniversalTime()) -format u))