$HS = Get-VMHost|  get-view
$HS.ShutdownHost("true")