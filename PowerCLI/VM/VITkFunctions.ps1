# Find the datacenter object that is hosting this cluster
Function get_cluster_datacenter
{
	Param
	(
	[VMware.VimAutomation.Client20.ClusterImpl]$cluster = $(throw "Must provide a cluster to get_cluster_datacenter.")
	)
	
	$clusview = Get-View $cluster.ID
	$parent = Get-View $clusview.Parent
	
	# Keep moving up the tree until we get to the datacenter
	for ($parent = (Get-View $clusview.Parent); `
					$parent.GetType().FullName -ne "VMware.Vim.Datacenter"; `
					$parent = (Get-View $parent.Parent))
	{}
	
	$parent
}

Function clone_template
{
	param
	(
		[String]$src_dc_name,
		[String]$dst_dc_name,
		[String]$tmpl_name,
		[String]$datastore_name,
		[String]$dst_host,
		[String]$dst_folder_name = "Templates"
	)
	
	$clone_spec = New-Object VMware.Vim.VirtualMachineCloneSpec
	$clone_spec.config = New-Object VMware.Vim.VirtualMachineConfigSpec
	$clone_spec.location = New-Object VMware.Vim.VirtualMachineRelocateSpec
	$clone_spec.location.transform = "sparse"
	$clone_spec.location.host = (Get-View (Get-VMhost $dst_host).ID).MoRef
	$clone_spec.location.datastore = (Get-View (Get-VMhost $dst_host | Get-Datastore $datastore_name).ID).MoRef
	$clone_spec.powerOn = $false
	$clone_spec.template = $true
	
	$dst_folder = Get-View (Get-Folder -Location (Get-Datacenter $dst_dc_name) -Name $dst_folder_name).ID
	$tmpl_view = Get-View (Get-Template -Location (Get-Datacenter $src_dc_name) -Name $tmpl_name).ID
	$clone_task_ref = $tmpl_view.CloneVM_Task($dst_folder.MoRef, $tmpl_name, $clone_spec)
	$clone_task = Get-ViObjectByVIView $clone_task_ref
	Wait-Task $clone_task | Out-Null
    
    # Get an updated view of the Task
    $clone_task = Get-ViObjectByVIView $clone_task_ref
    
	#Check task status and return something interesting
	if ($clone_task.State -eq "success") {$status = $true}
	elseif ($clone_task.State -eq "error") {$status = $false}
	
	$status
}