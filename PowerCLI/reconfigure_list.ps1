import-csv c:\1.csv | foreach {
   Get-VM $_.Name | get-networkadapter | set-networkadapter -networkname "VLAN147" -confirm:$false
   }
   import-csv c:\1.csv | foreach {
   Get-VM $_.Name | restart-vmguest
   }
