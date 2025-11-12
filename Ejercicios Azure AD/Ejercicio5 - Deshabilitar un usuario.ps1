#Deshabilitar un usuario

Set-AzureADUser -ObjectId "usuario@zrkdemo.onmicrosoft.com" -AccountEnabled $false
