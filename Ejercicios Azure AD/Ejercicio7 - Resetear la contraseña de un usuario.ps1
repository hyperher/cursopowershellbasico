#Resetear la contraseña de un usuario

Set-AzureADUserPassword -ObjectId "usuario@zrkdemo.onmicrosoft.com" -Password "NuevoP@ssw0rd2025" -ForceChangePasswordNextLogin $true
