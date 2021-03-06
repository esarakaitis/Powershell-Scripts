Function Get-SecureCredentialStoreItem
{
    Param
    (
        [String]$hostname = $null,
        [String]$username = $null,
        [String]$file = $null
    )
    
    $store = @(Load-SecureCredentialStoreFromFile $file)
    
    # Figure out what to return.
    if ($hostname -and $username)
    {
        $results = $store | Where-Object {$_.hostname -eq $hostname -and $_.credential.username -eq $username}
    }
    elseif ($hostname)
    {
        $results = $store | Where-Object {$_.hostname -eq $hostname}
    }
    elseif ($username)
    {
        $results = $store | Where-Object {$_.credential.username -eq $username}
    }
    else
    {
        $results = $store
    }
    
    # Give some love back to the caller.
    $results
}

Function New-SecureCredentialStoreItem
{
    Param
    (
        [String]$hostname = $(throw "New-SecureCredentialStoreItem: A hostname must be provided."),
        [String]$username = $(throw "New-SecureCredentialStoreItem: A username must be provided."),
        [System.Security.SecureString]$password = $(Read-Host "Credential Password:" -AsSecureString),
        [String]$file = $null
    )
    
    if (!$file)
    {
        $file = "{0}\SecureCredStore\credentials.xml" -f $env:APPDATA
    }
    
    $store = @() # Empty credential store.
    
    # Does the credential file exist?
    if ((Resolve-Path $file -ErrorAction SilentlyContinue))
    {
        $store = @(Load-SecureCredentialStoreFromFile $file)
    }
    
    # If there a credential stored for this host and user update it.
    $update = $false
    foreach ($item in $store)
    {
        if ($item.hostname -eq $hostname -and $item.credential.username -eq $username)
        {
            $item.credential = New-Object System.Management.Automation.PSCredential $username, $password
            $updated = $true
        }
    }
    
    if (!$updated) # It is a new item to add
    {
        $credItem = SecureCredentialStoreItem
        $credItem.hostname = $hostname
        $credItem.credential = New-Object System.Management.Automation.PSCredential $username, $password
        
        $store += $credItem
    }
    
    # Create the folder structure and an empty file if they do not exist.
    if (!(Resolve-Path $file -ErrorAction SilentlyContinue))
    {
        [void](New-Item -Path $file -ItemType File -Force)
    }
    
    [void](Save-SecureCredentialStoreToFile $store $file)
}

# Deletes based upon hostname, username, or both.
# Return an integer indicating the number of records removed.
Function Remove-SecureCredentialStoreItem
{
    Param
    (
        [String]$hostname = $null,
        [String]$username = $null,
        [String]$file = $null
    )
    
    $numDeleted = 0
    
    if (!$hostname -and !$username)
    {
        Write-Host "Remove-SecureCredentialStoreItem: Error - no hostname or username provided." -ForegroundColor Red
        $numDeleted
    }
    else
    {
        $store = @(Load-SecureCredentialStoreFromFile $file)
            
        # Figure out what to return.
        if ($hostname -and $username)
        {
            $keep = @($store | Where-Object {$_.hostname -ne $hostname -or $_.credential.username -ne $username})
        }
        elseif ($hostname)
        {
            $keep = @($store | Where-Object {$_.hostname -ne $hostname})
        }
        else
        {
            $keep = @($store | Where-Object {$_.credential.username -ne $username})
        }
        
        $numDeleted = $store.Length - $keep.Length
        
        # Save the file if there were any changes.
        if ($numDeleted -gt 0)
        {
            [void](Save-SecureCredentialStoreToFile $keep $file)
        }
        
        # Let the caller know how many records were deleted.
        $numDeleted
    }
}

Function Clear-SecureCredentialStoreItems
{
    Param
    (
        [String]$file = $null
    )
    
    if (!$file)
    {
        $file = "{0}\SecureCredStore\credentials.xml" -f $env:APPDATA
    }
    
    # Save an empty file
    $store = @()
    Save-SecureCredentialStoreToFile $store $file
}

Function Load-SecureCredentialStoreFromFile
{
    Param
    (
        [String]$file = $null
    )
    
    if (!$file)
    {
        $file = "{0}\SecureCredStore\credentials.xml" -f $env:APPDATA
    }
    
    # Does the credential file exist?
    if ((Resolve-Path $file -ErrorAction SilentlyContinue))
    {
        $credentialStore = @()
        
        $doc = [Xml](Get-Content $file)
        
        # Check for an incorrect root elememnt.
        if (!($doc | Get-Member credentials -ErrorAction SilentlyContinue))
        {
            Write-Host "Malformed credentials file: $file" -ForegroundColor Red
        }
        # Check to make sure that the document is not empty.
        elseif ($doc.credentials | Get-Member passwordEntry)
        {
            foreach ($entry in $doc.credentials.passwordEntry)
            {
                $credItem = SecureCredentialStoreItem
                $credItem.hostname = $entry.hostname
                $username = $entry.username
                $password = ($entry.password | ConvertTo-SecureString -ErrorAction SilentlyContinue -ErrorVariable $decryptError)
                
                # TODO: What to do with bad passwords?  Right now we exit, but that is not very user friendly.
                if ($password)
                {
                    $credItem.credential = New-Object System.Management.Automation.PSCredential $username, $password
                    $credentialStore += $credItem
                }
                else
                {
                    Write-Host "There was an error decrypting one of the passwords.  Credentials files are user/computer specific.  Exiting." -ForegroundColor Red
                    Exit
                }
            }
        }
        $credentialStore
    }
    else
    {
        Write-Host ("Credential file not found: {0}." -f $file) -ForegroundColor Red
    }
}

Function Save-SecureCredentialStoreToFile
{
    Param
    (
        $credentialStore,
        [String]$file = $null
    )

    if (!$file)
    {
        $file = "{0}\SecureCredStore\credentials.xml" -f $env:APPDATA
    }
    
    # Turn the credential store into XML
    $xmlDoc = New-Object System.Xml.XmlDocument
    $rootEl = $xmlDoc.CreateElement("credentials")
    
    foreach ($item in $credentialStore)
    {

        # Create the password entry
        $passEntryEl = $xmlDoc.CreateElement("passwordEntry")
        
        # Populate the elements
        $hostEl = $xmlDoc.CreateElement("hostname")
        $hostEl.set_InnerText($item.hostname)
        [void]$passEntryEl.AppendChild($hostEl)
        
        $userEl = $xmlDoc.CreateElement("username")
        $userEl.set_InnerText($item.credential.username)
        [void]$passEntryEl.AppendChild($userEl)
        
        $passEl = $xmlDoc.CreateElement("password")
        $textPass = $item.credential.password | ConvertFrom-SecureString
        $passEl.set_InnerText($textPass)
        [void]$passEntryEl.AppendChild($passEl)
        
        # Add the entry to the root element
        [void]$rootEl.AppendChild($passEntryEl)
    }

    # Add the contents to the document
    [void]$xmlDoc.AppendChild($rootEl)
    
    $xmlDoc.Save($file)    
}

Function SecureCredentialStoreItem
{
    $item = New-Object PSObject
    
    # Hostname
    $item | Add-Member -MemberType NoteProperty -Name hostname -Value ""
    
    # Username portion of the credential
    $item | Add-Member -MemberType ScriptProperty -Name username -Value `
            { # Get
                $this.credential.username
            } `
            { # Set
            
                param
                (
                    [String]$username
                )
                
                # Username is read only so we create a replacement credential.
                $newCred = New-Object System.Management.Automation.PSCredential $username, $this.credential.password
                $this.credential = $newCred
            }
    
    # Password portion of the credential
    $item | Add-Member -MemberType ScriptProperty -Name password -Value `
            { # Get
                $this.credential.password
            } `
            { # Set
            
                param 
                (
                    [System.Security.SecureString]$password
                )
                               
                # Password is read only so we create a replacement credential.
                $newCred = New-Object System.Management.Automation.PSCredential $this.credential.username, $password
                $this.credential = $newCred
            }
    
    # Credential
    $item | Add-Member -MemberType NoteProperty -Name credential -Value `
                       (New-Object System.Management.Automation.PSCredential "<empty>", 
                            (New-Object System.Security.SecureString))

    # In general I would recommend against using this, but there are times
    # when it must be done.  Done as a method so it is not run unless called
    # explicitly.  Setting should be done via the securestring password property.
    $item | Add-Member -MemberType ScriptMethod -Name passwordToPlainText -Value `
            {
                $ptr=[System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($this.credential.password)
                $str = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
                [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($ptr)
                $str
            }
    $item
}
