. .\SecureCredentialStoreItemFunctions.ps1

$credFile = ".\SecureCredentialStoreItemFunctions_Test.xml"
# Remove the previous credFile
Remove-Item $credFile -ErrorAction SilentlyContinue

$credentialLimit = 10 # The number of credential items to create.

# Test all unique items

# Create the test credential store items.
foreach ($i in 1..$credentialLimit)
{
    # Create the password as a secure string.
    $password = New-Object System.Security.SecureString
    foreach ($c in "Password$i".ToCharArray())
    {
        $password.AppendChar($c)
    }
    
    New-SecureCredentialStoreItem -file $credFile "host$i" "user$i" $password
}

# Validate that we get a correct number of items back with no criteria
$items = Get-SecureCredentialStoreItem -file $credFile 
if ($items)
{
    if (!$items.Length -eq $credentialLimit)
    {
        Write-Error "Test failed: Get-SecureCredentialStoreItem without criteria count is incorrect."
        continue
    }
    else
    {
        Write-Host "Test passed: Get-SecureCredentialStoreItem without criteria count is correct."
    }
}
else
{
    Write-Error "Test failed: Get-SecureCredentialStoreItem did not return any items."
}

# Validate each of the elements and test removing them.
foreach ($i in 1..$credentialLimit)
{
    $item = Get-SecureCredentialStoreItem -file $credFile -hostname "host$i" -username "user$i"
    if (!$item)
    {
        Write-Error "Test failed: could not find an item for host$i and user$i."
        continue
    }
    else
    {
        Write-Host "Test passed: finding an item for host$i and user$i."
    }
    
    if ($item.passwordToPlainText() -ne "Password$i")
    {
        Write-Error "Test failed: password incorrect for host$i and user$i."
        continue
    }
    else
    {
        Write-Host "Test passed: password for host$i and user$i."
    }
    
    $numRemoved = Remove-SecureCredentialStoreItem -file $credFile -hostname "host$i" -username "user$i"
    if ($numRemoved -ne 1)
    {
        Write-Error "Test failed: Wrong number of items removed for host$i and user$i ($numRemoved)"
        continue
    }
    else
    {
        Write-Host "Test passed: Correct number of items removed ($numRemoved)"
    }
    
    if (Get-SecureCredentialStoreItem  -file $credFile -hostname "host$i" -username "user$i")
    {
        Write-Errror "Test failed: Item found when none should have been returned for host$i and user$i"
        continue
    }
    else
    {
        Write-Host "Test passed: Item removed successfully."
    }
}

# Test items with the same hostname.
# Create the test credential store items with the.
$numCreds = $credentialLimit / 2
foreach ($i in 1..$numCreds)
{
    New-SecureCredentialStoreItem -file $credFile "deleteme" "user$i" $password
}

$numCreds = $credentialLimit / 2
foreach ($i in 1..$numCreds)
{
    New-SecureCredentialStoreItem -file $credFile "keepme" "user$i" $password
}

$items = Get-SecureCredentialStoreItem -file $credFile -host "deleteme"
if (!$items -or ($items.Length -ne $numCreds))
{
    Write-Error "Test failed: Retrieving items by hostname count is incorrect."
}
else
{
    Write-Host "Test passed: Retrieving items by hostname count is correct."
}

$numRemoved = Remove-SecureCredentialStoreItem  -file $credFile -host "deleteme"
if ($numRemoved -ne $numCreds)
{
    Write-Error "Test failed: Removing items by hostname count is incorrect."
}
else
{
    Write-Host "Test passed: Removing items by hostname count is correct."
}

$items = Get-SecureCredentialStoreItem -file $credFile -host "keepme"
if (!$items -or ($items.Length -ne $numCreds))
{
    Write-Error "Test failed: Removing items by hostname deleted extra items."
}
else
{
    Write-Host "Test passed: Retrieving items by hostname left the correct items."
}

# Test that the store is cleared
Clear-SecureCredentialStoreItems -file $credFile
$items = Get-SecureCredentialStoreItem -file $credFile 
if ($items)
{
    Write-Error "Test passed: Clear-SecureCredentialStoreItems"
    continue
}
else
{
    Write-Host "Test passed: Clear-SecureCredentialStoreItems"
}

# Test items with the same username.
# Create the test credential store items with the.
$numCreds = $credentialLimit / 2
foreach ($i in 1..$numCreds)
{
    New-SecureCredentialStoreItem -file $credFile "host$i" "baduser" $password
}

$numCreds = $credentialLimit / 2
foreach ($i in 1..$numCreds)
{
    New-SecureCredentialStoreItem -file $credFile "host$i" "gooduser" $password
}

$items = Get-SecureCredentialStoreItem -file $credFile -username "baduser"
if (!$items -or ($items.Length -ne $numCreds))
{
    Write-Error "Test failed: Retrieving items by username count is incorrect."
}
else
{
    Write-Host "Test passed: Retrieving items by username count is correct."
}

$numRemoved = Remove-SecureCredentialStoreItem  -file $credFile -username "baduser"
if ($numRemoved -ne $numCreds)
{
    Write-Error "Test failed: Removing items by username count is incorrect."
}
else
{
    Write-Host "Test passed: Removing items by username count is correct."
}

$items = Get-SecureCredentialStoreItem -file $credFile -username "gooduser"
if (!$items -or ($items.Length -ne $numCreds))
{
    Write-Error "Test failed: Removing items by username deleted extra items."
}
else
{
    Write-Host "Test passed: Retrieving items by username left the correct items."
}

Write-Host "TESTING ODD RUNTIME CONDITIONS"
Write-Host "Test using a credentials file with a bad root element."
$data = "<notcredentials/>"
$data > $credFile
$items = Get-SecureCredentialStoreItem -file $credFile
Write-Host "The test should have thrown a user friendly error.  Exceptions and PowerShell are rather ugly."


Write-Host "Test using an empty credentials file."
$data = "<credentials/>"
$data > $credFile
$items = Get-SecureCredentialStoreItem -file $credFile
Write-Host "The test should have run fine, but with no output."

Write-Host "Test using a credentials file with an undecryptable password."
$data = "<credentials><passwordEntry><hostname>myHost</hostname><username>myUser</username><password>myBadPassword</password></passwordEntry></credentials>"
$data > $credFile
$items = Get-SecureCredentialStoreItem -file $credFile
Write-Host "The test should have thrown a user friendly error.  Exceptions and PowerShell are rather ugly."
