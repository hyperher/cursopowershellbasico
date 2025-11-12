#Delegar permisos de administración en una OU
$ou = "OU=Biblioteca,OU=Ayuntamiento,$((Get-ADDomain).DistinguishedName)"
$user = Get-ADUser -Identity csantos
dsacls $ou /G "$($user.SID):CA;Create;user"
