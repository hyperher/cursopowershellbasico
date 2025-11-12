# 1. Conectarse a Azure AD con PowerShell
Connect-AzureAD -TenantId "zrkdemo.onmicrosoft.com"

# 2. Listar todos los usuarios habilitados en el tenant
Get-AzureADUser -All $true | Where-Object {$_.AccountEnabled -eq $true} | Select DisplayName, UserPrincipalName

# 3. Buscar un usuario específico por UserPrincipalName
Get-AzureADUser -ObjectId "mhernandez@zrkdemo.onmicrosoft.com"

# 4. Crear un usuario nuevo (ejemplo usuario prueba)
New-AzureADUser -DisplayName "Usuario Prueba" -PasswordProfile @{Password = "P@ssw0rd123"} -UserPrincipalName "usuarioprueba@zrkdemo.onmicrosoft.com" -AccountEnabled $true -MailNickName "usuarioprueba"

# 5. Habilitar o deshabilitar una cuenta de usuario
Set-AzureADUser -ObjectId "prueba1@zrkdemo.onmicrosoft.com" -AccountEnabled $false

# 6. Actualizar el título del trabajo de un usuario
Set-AzureADUser -ObjectId "Daniel.Hernandez@zrkdemo.onmicrosoft.com" -JobTitle "Administrador IT"

# 7. Listar todos los usuarios invitados (Guest)
Get-AzureADUser -All $true | Where-Object {$_.UserType -eq "Guest"} | Select DisplayName, UserPrincipalName, Mail

# 8. Eliminar un usuario
Remove-AzureADUser -ObjectId "testuser@zrkdemo.onmicrosoft.com"

# 9. Resetear la contraseña de un usuario (requiere módulo MSOnline)
Set-MsolUserPassword -UserPrincipalName "admin@zrkdemo.onmicrosoft.com" -NewPassword "NuevoP@ssw0rd123" -ForceChangePassword $false

# 10. Obtener detalles de un usuario y exportarlos a CSV
Get-AzureADUser -ObjectId "mhernandez@zrkdemo.onmicrosoft.com" | Select DisplayName, UserPrincipalName, JobTitle, Department, AccountEnabled | Export-Csv -Path "C:\temp\usuario.csv" -NoTypeInformation

# 11. Listar usuarios por departamento
Get-AzureADUser -All $true | Where-Object {$_.Department -eq "Finanzas"} | Select DisplayName, UserPrincipalName

# 12. Buscar usuarios que no tienen correo asociado
Get-AzureADUser -All $true | Where-Object { -not $_.Mail } | Select DisplayName, UserPrincipalName

# 13. Agregar un usuario a un grupo
$group = Get-AzureADGroup -SearchString "Administradores"
Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId (Get-AzureADUser -ObjectId "admin@zrkdemo.onmicrosoft.com").ObjectId

# 14. Mostrar usuarios creados en los últimos 30 días
Get-AzureADUser -All $true | Where-Object { $_.CreatedDateTime -gt (Get-Date).AddDays(-30) } | Select DisplayName, UserPrincipalName, CreatedDateTime

# 15. Exportar todos los usuarios a un CSV con campos básicos
Get-AzureADUser -All $true | Select DisplayName, UserPrincipalName, JobTitle, Department, AccountEnabled, UsageLocation | Export-Csv -Path "C:\temp\usuarios.csv" -NoTypeInformation