#$_.Name corresponds to column title Name
#$_.NewDatastore corresponds to column title NewDatastore
Import-Csv c:\import.csv | Foreach {
    Get-VM $_.Name | Move-VM -DiskStorageFormat Thin -Datastore $_.NewDatastore -RunAsync
	}
