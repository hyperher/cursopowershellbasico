#Auditar cambios en grupos críticos

Get-ADGroupMember "Informática-Admins" | Select Name,SamAccountName | Export-Csv .\Miembros-IT.csv
# Más tarde:
Compare-Object (Import-Csv .\Miembros-IT.csv) (Get-ADGroupMember "Informática-Admins" | Select Name,SamAccountName)
