get-vmhost | foreach-object `
{$vmhost=$_
(get-compliance $vmhost).notcompliantupdates}