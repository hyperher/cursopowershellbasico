# Listar todos los usuarios habilitados en el tenant
Get-AzureADUser -All $true | Where-Object {$_.AccountEnabled -eq $true} | Select DisplayName, UserPrincipalName
