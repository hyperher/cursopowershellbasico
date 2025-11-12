#Crear OU nueva para "Empleo Temporal" y mover usuarios allí
New-ADOrganizationalUnit -Name "Empleo Temporal" -Path "OU=Ayuntamiento,$((Get-ADDomain).DistinguishedName)" -ProtectedFromAccidentalDeletion $false
Move-ADObject (Get-ADUser temporal01).DistinguishedName -TargetPath "OU=Empleo Temporal,OU=Ayuntamiento,$((Get-ADDomain).DistinguishedName)"
