#Crear grupos nuevos y añadir usuarios
New-ADGroup -Name "Obras-Personal" -GroupScope Global -Path "OU=Grupos,OU=Ayuntamiento,$((Get-ADDomain).DistinguishedName)"
Add-ADGroupMember -Identity "Obras-Personal" -Members "pruiz","agarcia"