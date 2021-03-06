# 
# Sample script to install the VITK Extensions on a per user basis.

param
(
    [switch]$overwrite # Specifying this switch will overwrite the existing files.
)

"Installation script starting."

# Find the user module location.
$myModulePath = ($Env:PSMODULEPATH -Split ";")[0]
$ViTkFile = "viToolKitExtensions.psm1"
$ViTkPath = $myModulePath + "\" + $ViTkFile
$profile = [System.Environment]::GetFolderPath("MyDocuments") + "\WindowsPowerShell\profile.ps1"

# Make sure the installation copy of the module exists.
if (-not (Resolve-Path $ViTkFile -ErrorAction SilentlyContinue))
{
    "`tVI Toolkit Extensions module not found in the current directory.  Exiting."
    exit
}

# Make a directory for the modules if it doesn't exist.
if (-not (Resolve-Path $myModulePath -ErrorAction SilentlyContinue))
{
    "`tUser module directory does not exist.  Creating {0}." -f $myModulePath
    [void](New-Item -Type Container -Force -path $myModulePath)
}

# No previous installation - copy and add auto load to the profile.
if (-not (Resolve-Path $ViTkPath -ErrorAction SilentlyContinue))
{
    "`tInstalling the module"
    Copy-Item $ViTkFile -Destination $myModulePath
    
    # Add module auto load to the profile.
    "`tAdding auto-import lines into your PowerShell profile."
    $loadCommand = "`n`n#Auto Import the VITK Extensions Module`nImport-Module `"$ViTkPath`""
    Add-Content -path "$profile" -Value $loadCommand
}
elseif ($overwrite)
{
    "`tOverwriting the existing module."
    
    # Make a backup copy of the existing file.
    $dateString = Get-Date -Format "yyyyMMddhhmmss"
    Copy-Item $ViTkPath -Destination ($ViTkPath + $dateString)
    
    # Replace the module with the new one.
    Copy-Item -Force $ViTkFile -Destination $ViTkPath
}
else
{
    "`tModule is already installed and the -overwrite parameter was not given."
}

"Installation script complete."