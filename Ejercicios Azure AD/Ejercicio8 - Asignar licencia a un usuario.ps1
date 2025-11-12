#Asignar licencia a un usuario


# Lista las licencias disponibles
Get-AzureADSubscribedSku | Select SkuPartNumber, SkuId

# Asignar licencia (reemplaza SkuId por el correcto)
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = "<SkuId>"
$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$Licenses.AddLicenses = $License

Set-AzureADUserLicense -ObjectId "usuario@zrkdemo.onmicrosoft.com" -AssignedLicenses $Licenses
