#Crear un nuevo usuario (básico)

New-AzureADUser -DisplayName "Juan Pérez" -UserPrincipalName "juan.perez@zrkdemo.onmicrosoft.com" -AccountEnabled $true -MailNickName "juan.perez" -PasswordProfile @{ForceChangePasswordNextSignIn=$true; Password="P@ssw0rd123"}
