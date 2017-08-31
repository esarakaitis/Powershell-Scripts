<#
.SYNOPSIS
	Simple invoke query command.
.DESCRIPTION
	Used for running queries against SQL servers, very flexible, native cmdlet.
.EXAMPLE
	.\ps-InvokeSQLQuery.ps1 -sqlServerName <SQLSERVER_NAME> -sqlDatabaseName <SQLDATABASE_NAME> -Query <SQLQUERY>
.NOTES
	*** REQUIRES SQL SNAPPINS ***
.LINK
	http://technet.microsoft.com/en-us/library/cc281720.aspx
	
#>
PARAM([STRING]$sqlServerName,[STRING]$sqlDatabaseName,[STRING]$query)
$results = Invoke-Sqlcmd -ServerInstance $sqlServerName -Database $sqlDatabaseName -Query $query
$results | ft *
