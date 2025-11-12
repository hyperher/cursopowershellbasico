#Automatizar un informe mensual de personal
$fecha = Get-Date -Format "yyyyMMdd"
Get-ADUser -Filter * -Properties Department | 
Group-Object Department | 
Select Name,Count | 
Export-Csv ".\InformePersonal_$fecha.csv" -NoTypeInformation
