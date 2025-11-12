#Crear una copia de seguridad de usuarios (backup a CSV)

Get-ADUser -Filter * -Properties Department,Title | 
Select Name,SamAccountName,Department,Title | 
Export-Csv .\BackupUsuarios.csv -NoTypeInformation