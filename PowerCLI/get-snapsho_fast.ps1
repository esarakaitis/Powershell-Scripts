$VCList = @("vcentsy01ewdu.oa.oclc.org","vcentsy02ewdu.oa.oclc.org","vcentsy03ewdu.oa.oclc.org","vcentsy04ewdu.oa.oclc.org","vcentsy05ewdu.oa.oclc.org", "vcentsy08ewdu.oa.oclc.org", "vcentsy06ewdu.oa.oclc.org","vcentsy07ewdu.oa.oclc.org","vcentsy01ewwe.oa.oclc.org")

    ForEach ($VC in ($VCList | Sort-Object)) {
        
        Connect-VIServer -Server $VC 

$snaplist = Get-View -ViewType VirtualMachine -Filter @{"snapshot"="$snaplist"}
$snaplist | select name
