#Establecer fecha de caducidad en cuentas temporales
New-ADUser -Name "Temporal01" -SamAccountName "temporal01" `
-Department "Secretaría" -AccountExpirationDate (Get-Date).AddDays(30) `
-AccountPassword (ConvertTo-SecureString "Temporal2025!" -AsPlainText -Force) -Enabled $true
