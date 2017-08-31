#Author:		Eric Wannemacher
#Version:		200809261317
#Description:	Gathers information about LUNs/paths for validation/troubleshooting

# Assumes that only one VMFS volume is on a LUN
# TODO: Update to handle multiple partitions on a LUN

# Set up the functions needed for processing the host objects.
BEGIN
{
# Returns a mapping of lun ids to Vendor names
function get_lun_vendor_map($vmhostview)
{
	$result = @{}
	$vmhostview.config.storagedevice.scsilun | ForEach-Object { `
		$result[$_.CanonicalName] = $_.Vendor
	}
	$result
}

# Returns a mapping of lun ids to VMFS volume friendly names
function get_lun_vmfs_map($vmhostview)
{
	$result = @{}
	$vmhostview.config.filesystemvolume.mountinfo | ForEach-Object { `
		$_.Volume | ForEach-Object { `
			$volname = $_.Name
			$_.extent | ForEach-Object { `
				$result[$_.DiskName] = $volname
			}
		}
	}
	$result
}

# Returns a combined list of path data with vendor and vmfs volume names
function get_path_details($vmhostview, $vendor_map, $vmfs_map)
{
	$i = 0
	$result = @()
	$vmhostview.config.storagedevice.multipathinfo.lun | ForEach-Object { `
		$lunid=$_.id
		$lunpolicy=$_.policy.policy
		$_.path | ForEach-Object {
			$result += $_ | Select-Object @{name="Hostname"; expression={$vmhostview.name}},
				@{name="Volume"; expression={$vmfs_map[$lunid]}},
				@{name="Lun"; expression={$lunid}},
				@{name="Vendor"; expression={$vendor_map[$lunid]}},
				@{name="LunPolicy"; expression={$lunpolicy}},
				@{name="PathState"; expression={$_.pathstate}}
		}
	}
	$result
}
}

# Process the host objects one at a time
PROCESS
{
$vmhostview = Get-View $_.id

$lun_vendor_map = get_lun_vendor_map $vmhostview
$lun_vmfs_map = get_lun_vmfs_map $vmhostview

# Output the object to the stream
get_path_details $vmhostview $lun_vendor_map $lun_vmfs_map 
}

# Finish up
END
{
}