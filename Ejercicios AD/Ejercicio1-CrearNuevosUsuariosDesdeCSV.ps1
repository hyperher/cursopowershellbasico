$usuarios = Import-Csv .\usuarios.csv
foreach ($u in $usuarios) {
    New-ADUser -Name "$($u.Nombre) $($u.Apellido)" -SamAccountName $u.SamAccountName `
        -Department $u.Departamento -Title $u.Puesto `
        -Path "OU=Usuarios,OU=$($u.Departamento),OU=Ayuntamiento,$((Get-ADDomain).DistinguishedName)" `
        -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
}
