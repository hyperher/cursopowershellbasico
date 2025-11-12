#Listar todos los grupos

Get-AzureADGroup -All $true | Select DisplayName, Description, GroupTypes
