get-adcomputer -properties lastLogonDate -filter * | where { $_.lastLogonDate -lt (get-date).addmonths(-6) } | FT Name,LastLogonDate > c:\test.txt

