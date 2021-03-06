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