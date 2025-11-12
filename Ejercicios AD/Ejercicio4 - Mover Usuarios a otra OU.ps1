#Mover Usuarios a otra OU
$user = Get-ADUser -Identity "lmoreno"
Move-ADObject -Identity $user.DistinguishedName `
    -TargetPath "OU=Usuarios,OU=Intervención,OU=Ayuntamiento,$((Get-ADDomain).DistinguishedName)"
