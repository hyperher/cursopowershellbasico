#Restablecer Contraseñas en Masa
Get-ADUser -Filter {Department -eq "Intervención"} | 
Set-ADAccountPassword -NewPassword (ConvertTo-SecureString "Cambio2025!" -AsPlainText -Force) -Reset
Get-ADUser -Filter {Department -eq "Intervención"} | 
Set-ADUser -ChangePasswordAtLogon $true