
$objSID = New-Object System.Security.Principal.SecurityIdentifier `
    ("s-1-5-21-1220945662-573735546-1417001333-500")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value