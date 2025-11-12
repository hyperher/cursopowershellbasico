#Buscar usuarios deshabilitados

Get-AzureADUser -All $true | Where-Object {$_.AccountEnabled -eq $false} | Select DisplayName, UserPrincipalName
