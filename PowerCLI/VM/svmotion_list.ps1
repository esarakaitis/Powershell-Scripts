import-csv c:\1.csv | foreach {
   Get-VM $_.Name | move-vm -datastore (get-datastore "datastore")
}