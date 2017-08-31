# Script to poll the current Broker information in XenDesktop and output to a CSV file
# File names are created with a date and timestamp in the name for repeated runs

# Matt Hyclak - matt.hyclak@cbts.cinbell.com
#
# 0.1 8/22/2012 - First attempt
# 0.2 8/24/2012 - Create a directory structure for storage of csvs.

Add-PSSnapIn citrix*

$FilenamePrefix ="brokerdata-"
$Timestamp = (Get-Date -Format yyyy-MM-dd-HHmm)
$DestBase = "C:\BrokerData"
$DestDir = "$DestBase\" + $Timestamp.Substring(0,$Timestamp.length-5)
$DestFile = "$DestDir\$FilenamePrefix$Timestamp.csv"

# Create a directory structure
if(!(Test-Path -PathType container $DestDir)) {
	mkdir $DestDir
}

# Can't use Format-Table because some of the returned items are objects themselves. Have to explode them into strings.
Get-BrokerDesktop | Select-Object AgentVersion,@{l="ApplicationsInUse";e={$_.ApplicationsInUse -join " "}},AssignedClientName,AssignedIPAddress,@{l="AssociatedUserFullNames";e={$_.AssociatedUserFullNames -join " "}},@{l="AssociatedUserNames";e={$_.AssociatedUserNames -join " "}},@{l="AssociatedUserUPNs";e={$_.AssociatedUserUPNs -join " "}},AutonomouslyBrokered,CatalogKind,CatalogUid,ClientAddress,ClientName,ClientVersion,ColorDepth,ConnectedViaHostName,ConnectedViaIP,ControllerDNSName,DNSName,Description,@{l="DesktopConditions";e={$_.DesktopConditions -join " "}},DesktopGroupName,DesktopGroupUid,DesktopKind,DeviceId,HardwareId,HostedMachineName,HostingServerName,HypervisorConnectionName,HypervisorConnectionUid,IPAddress,IconUid,ImageOutOfDate,InMaintenanceMode,IsAssigned,LastConnectionFailure,LastConnectionTime,LastConnectionUser,LastDeregistrationReason,LastDeregistrationTime,LastHostingUpdateTime,LaunchedVIaHostName,LaunchedViaIP,LicenseID,MachineName,MachineUid,OSType,OSVersion,PowerActionPending,PowerState,Protocol,@{l="PublishedApplications";e={$_.PublishedApplications -join " "}},PublishedName,RegistrationState,SID,SecureIcaActive,SecureIcaRequired,SessionId,SessionState,SessionStateChangeTime,SessionUid,SessionUserName,SessionUserSID,SmartAccessTags,StartTime,SummaryState,@{l="Tags";e={$_.Tags -join " "}},Uid,WillShutdownAfterUse | Export-CSV $DestFile

# If we don't need everything, just select a subset
# Get-BrokerDesktop | Select-Object AgentVersion,AssignedClientName,AssignedIPAddress,@{l="AssociatedUserFullNames";e={$_.AssociatedUserFullNames -join " "}},ClientAddress,ClientName,ClientVersion | Export-CSV $DestFile

