get-aduser -f {-not ( lastlogontimestamp -like "*") -and (enabled -eq $true)} | select name
