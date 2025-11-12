#Asignar directorios personales y rutas de perfil
Get-ADUser csantos | Set-ADUser -HomeDirectory "\\Servidor\Usuarios\csantos" -HomeDrive "H:" -ProfilePath "\\Servidor\Perfiles\csantos"
