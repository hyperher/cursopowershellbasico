Import-Module ActiveDirectory

# Ajustes básicos
$root = (Get-ADDomain).DistinguishedName
$orgName = "Ayuntamiento"

# Contraseña temporal (puedes cambiarla)
$plainPassword = "P@ssw0rd123!"
$securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

Write-Host "Dominio raíz: $root" -ForegroundColor Cyan

# 1️⃣ Crear OU principal y sub-OUs
$ouAyto = "OU=$orgName,$root"
New-ADOrganizationalUnit -Name $orgName -Path $root -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue

$departamentos = @(
    "Alcaldía",
    "Secretaría",
    "Intervención",
    "Informática",
    "Policía Local",
    "Obras y Servicios",
    "Biblioteca",
    "Servicios Sociales"
)

foreach ($d in $departamentos) {
    $ou = "OU=$d,$ouAyto"
    New-ADOrganizationalUnit -Name $d -Path $ouAyto -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
    # Subcarpetas de usuarios y equipos
    New-ADOrganizationalUnit -Name "Usuarios" -Path $ou -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
    New-ADOrganizationalUnit -Name "Equipos" -Path $ou -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
}

# OU para grupos
New-ADOrganizationalUnit -Name "Grupos" -Path $ouAyto -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue

# 2️⃣ Crear algunos usuarios de ejemplo
$usuarios = @(
    @{Nombre="Ana";   Apellido="García";    Sam="agarcia";   Dpto="Secretaría";         Puesto="Administrativa"},
    @{Nombre="Luis";  Apellido="Martínez";  Sam="lmartinez"; Dpto="Intervención";       Puesto="Contable"},
    @{Nombre="María"; Apellido="López";     Sam="mlopez";    Dpto="Servicios Sociales"; Puesto="Trabajadora Social"},
    @{Nombre="Carlos";Apellido="Santos";    Sam="csantos";   Dpto="Informática";        Puesto="Técnico Informático"},
    @{Nombre="Irene"; Apellido="Vega";      Sam="ivega";     Dpto="Biblioteca";         Puesto="Bibliotecaria"},
    @{Nombre="Pedro"; Apellido="Ruiz";      Sam="pruiz";     Dpto="Obras y Servicios";  Puesto="Operario"},
    @{Nombre="Sergio";Apellido="Díaz";      Sam="sdiaz";     Dpto="Policía Local";      Puesto="Agente"},
    @{Nombre="Lucía"; Apellido="Moreno";    Sam="lmoreno";   Dpto="Secretaría";         Puesto="Auxiliar"},
    @{Nombre="Rosa";  Apellido="Ortiz";     Sam="rortiz";    Dpto="Intervención";       Puesto="Tesorera"},
    @{Nombre="Javier";Apellido="Navarro";   Sam="jnavarro";  Dpto="Informática";        Puesto="Soporte Técnico"}
)

foreach ($u in $usuarios) {
    $ouUsuariosPath = "OU=Usuarios,OU=$($u.Dpto),$ouAyto"
    $sam = $u.Sam
    $nombreCompleto = "$($u.Nombre) $($u.Apellido)"

    if (-not (Get-ADUser -Filter {SamAccountName -eq $sam} -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $nombreCompleto `
                   -GivenName $u.Nombre -Surname $u.Apellido `
                   -SamAccountName $sam `
                   -UserPrincipalName "$sam@$(Get-ADDomain).DNSRoot" `
                   -Path $ouUsuariosPath `
                   -AccountPassword $securePassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -Title $u.Puesto `
                   -Department $u.Dpto
        Write-Host "✅ Creado usuario: $nombreCompleto ($sam)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  El usuario $sam ya existe. Omitido." -ForegroundColor Yellow
    }
}

# 3️⃣ Crear grupos y asignar miembros
$grupos = @(
    @{Nombre="Personal-Ayuntamiento"; Tipo="Global"; Miembros=@("agarcia","lmartinez","mlopez","lmoreno","rortiz")},
    @{Nombre="Informática-Admins";   Tipo="Global"; Miembros=@("csantos","jnavarro")},
    @{Nombre="Intervención-Equipo";  Tipo="Global"; Miembros=@("lmartinez","rortiz")},
    @{Nombre="PolicíaLocal-Plantilla"; Tipo="Global"; Miembros=@("sdiaz")},
    @{Nombre="Biblioteca-Equipo";    Tipo="Global"; Miembros=@("ivega")}
)

$ouGrupos = "OU=Grupos,$ouAyto"
foreach ($g in $grupos) {
    if (-not (Get-ADGroup -Filter {Name -eq $g.Nombre} -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $g.Nombre -GroupScope $g.Tipo -GroupCategory Security -Path $ouGrupos -Description "Grupo para $($g.Nombre)"
        Write-Host "📘 Creado grupo: $($g.Nombre)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  El grupo $($g.Nombre) ya existe. Omitido." -ForegroundColor Yellow
    }

    foreach ($m in $g.Miembros) {
        $usr = Get-ADUser -Filter {SamAccountName -eq $m} -ErrorAction SilentlyContinue
        if ($usr) {
            Add-ADGroupMember -Identity $g.Nombre -Members $usr.SamAccountName -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "`n🎯 Estructura del Ayuntamiento creada correctamente." -ForegroundColor Magenta
Write-Host "Contraseña temporal de los usuarios: $plainPassword (forzar cambio al iniciar sesión)." -ForegroundColor Magenta
