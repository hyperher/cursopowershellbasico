#Generar informe de usuarios por departamento
Get-ADUser -Filter * -Properties Department,Title | 
Select Name,SamAccountName,Department,Title | 
Export-Csv .\UsuariosPorDepartamento.csv -NoTypeInformation
