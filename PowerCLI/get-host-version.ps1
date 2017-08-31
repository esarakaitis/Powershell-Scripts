$FullName = @{ Label = "Product Full Name"; Expression = { (Get-View $_.ID).Config.Product.fullname } }
Get-VMHost | Sort-object name | ft name,$fullname  