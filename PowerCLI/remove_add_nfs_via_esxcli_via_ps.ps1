$getcli = Get-EsxCli -VMhost r1b41g.idaho.cbts.net
$getcli.storage.nfs.remove("nfs0")
$getcli.storage.nfs.add("nfs0.idaho.cbts.net","/nfs0","nfs0")