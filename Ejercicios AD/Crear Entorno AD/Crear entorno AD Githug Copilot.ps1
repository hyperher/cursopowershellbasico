<#!
.SYNOPSIS
 Script de laboratorio para crear un entorno de Active Directory de un Ayuntamiento (~5000 hab.) con OUs, usuarios y grupos (5 usuarios por departamento).
.DESCRIPTION
 Versión del script que crea exactamente 5 usuarios en cada departamento definido. Idempotente: solo crea lo que falta.
 Incluye funciones para reporte y limpieza. Todo se etiqueta con un Tag de fecha para facilitar su eliminación.

REQUISITOS:
 - RSAT / módulo ActiveDirectory instalado.
 - Permisos adecuados en el dominio.

.PARAMETER RootOUName
 Nombre de la OU raíz del laboratorio (por defecto AytoLab5).
.PARAMETER DryRun
 Muestra acciones sin ejecutar cambios.
.PARAMETER Verbose
 Trazas informativas.

.EXAMPLE
 .\CrearEntornoAD_5.ps1 -Verbose
 Crea entorno completo con 5 usuarios por departamento.
.EXAMPLE
 .\CrearEntornoAD_5.ps1 -RootOUName "AytoLabCurso" -DryRun
 Simula las acciones.

.NOTES
 Tag: LAB AytoCurso <yyyyMMdd>
 Version: 1.0 (variante 5 usuarios)
#>
param(
    [string]$RootOUName = "AytoLab5",
    [switch]$DryRun,
    [switch]$Verbose
)

# Tabla fija de 5 usuarios por departamento
$UserCounts = @{ Alcaldia=5; Secretaria=5; Intervencion=5; Tesoreria=5; Urbanismo=5; ServiciosMunicipales=5; RecursosHumanos=5; TIC=5; Policia=5 }

# Globales
$Global:AytoLabTag = "LAB AytoCurso $(Get-Date -Format yyyyMMdd)"
$Global:Deptos = @("Alcaldia","Secretaria","Intervencion","Tesoreria","Urbanismo","ServiciosMunicipales","RecursosHumanos","TIC","Policia")

function Write-Action { param([string]$Message); if($Verbose){ Write-Host "[INFO] $Message" -ForegroundColor Cyan } }

function Test-ModuleAD {
    if(-not (Get-Module -Name ActiveDirectory -ListAvailable)){ throw "No se encuentra el módulo ActiveDirectory. Instale RSAT." }
    if(-not (Get-Module ActiveDirectory)){ Import-Module ActiveDirectory -ErrorAction Stop }
    try { $null = Get-ADDomain } catch { throw "No se pudo consultar el dominio: $($_.Exception.Message)" }
}

function New-RandomPassword { param([int]$Length = 12)
    if($Length -lt 8){ throw "Length mínimo 8" }
    $upper = -join ((65..90) | Get-Random -Count 2 | ForEach-Object {[char]$_})
    $lower = -join ((97..122) | Get-Random -Count 4 | ForEach-Object {[char]$_})
    $digits = -join ((0..9) | Get-Random -Count 2)
    $symbolsSet = '!@#$%&*+-_?'
    $symbols = -join ($symbolsSet.ToCharArray() | Get-Random -Count 2)
    $remainingCount = $Length - ($upper.Length + $lower.Length + $digits.Length + $symbols.Length)
    $remaining = -join ((33..126) | Get-Random -Count $remainingCount | ForEach-Object {[char]$_})
    $raw = ($upper + $lower + $digits + $symbols + $remaining).ToCharArray() | Get-Random -Count $Length
    -join $raw
}

function Ensure-OUs { param([string]$RootOU)
    Write-Action "Creando jerarquía de OUs (si falta)"
    $domainDN = (Get-ADDomain).DistinguishedName
    $rootDN = "OU=$RootOU,$domainDN"
    $ouList = @($rootDN,"OU=Trabajadores,$rootDN","OU=CuentasServicio,$rootDN","OU=Grupos,$rootDN","OU=Equipos,$rootDN","OU=Proyectos,$rootDN")
    foreach($d in $Global:Deptos){ $ouList += "OU=$d,OU=Trabajadores,$rootDN" }
    foreach($p in @("SmartTown","PortalTransparencia","InventarioDigital")){ $ouList += "OU=$p,OU=Proyectos,$rootDN" }
    foreach($ouDN in $ouList){
        $exists = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouDN)" -ErrorAction SilentlyContinue
        if($exists){ Write-Action "OU existe: $ouDN"; continue }
        if($DryRun){ Write-Host "[DRYRUN] Crear OU $ouDN" -ForegroundColor Yellow }
        else { New-ADOrganizationalUnit -Name ($ouDN -split ',')[0].Substring(3) -Path (($ouDN -split ',') | Select-Object -Skip 1 -Join ',') -Description $AytoLabTag -ProtectedFromAccidentalDeletion:$false; Write-Action "OU creada: $ouDN" }
    }
    return $rootDN
}

function Ensure-Groups { param([string]$RootOU)
    $groupsOU = "OU=Grupos,$RootOU"
    $toCreate = @()
    foreach($d in $Global:Deptos){ $toCreate += "SG_${d}_Trabajadores","FS_${d}_RW","FS_${d}_RO" }
    $toCreate += "SG_Comite_Direccion","SG_Proyecto_SmartTown","SG_Prevencion_Riesgos","SG_Incidencias_TIC","SG_Control_Acceso_Policia"
    foreach($g in $toCreate){
        $exists = Get-ADGroup -Filter "(samAccountName=$g)" -SearchBase $groupsOU -ErrorAction SilentlyContinue
        if($exists){ Write-Action "Grupo existe: $g"; continue }
        if($DryRun){ Write-Host "[DRYRUN] Crear Grupo $g" -ForegroundColor Yellow }
        else { New-ADGroup -Name $g -SamAccountName $g -GroupCategory Security -GroupScope Global -Path $groupsOU -Description "$AytoLabTag $g"; Write-Action "Grupo creado: $g" }
    }
}

function New-DeptUsers { param([string]$RootOU,[hashtable]$Counts)
    foreach($dept in $Global:Deptos){
        $count = if($Counts.ContainsKey($dept)){ [int]$Counts[$dept] } else { 0 }
        if($count -le 0){ continue }
        $deptOU = "OU=$dept,OU=Trabajadores,$RootOU"
        $groupDept = "SG_${dept}_Trabajadores"
        Write-Action "Usuarios en $dept: $count"
        for($i=1;$i -le $count;$i++){
            $given = $dept.Substring(0,[Math]::Min(6,$dept.Length))
            $sn = "Usuario$i"
            $sam = ($given + $i).ToLower().Replace('í','i').Replace('ó','o').Replace('á','a')
            $exists = Get-ADUser -Filter "(samAccountName=$sam)" -SearchBase $deptOU -ErrorAction SilentlyContinue
            if($exists){ Write-Action "Ya existe: $sam"; continue }
            $pwd = New-RandomPassword -Length 14
            $secure = ConvertTo-SecureString $pwd -AsPlainText -Force
            if($DryRun){ Write-Host "[DRYRUN] Crear Usuario $sam en $deptOU" -ForegroundColor Yellow; continue }
            New-ADUser -Name "$given $sn" -SamAccountName $sam -GivenName $given -Surname $sn -DisplayName "$given $sn" -Path $deptOU -AccountPassword $secure -Enabled $true -ChangePasswordAtLogon $true -Description "$AytoLabTag Usuario laboratorio" -PasswordNeverExpires $true
            Add-ADGroupMember -Identity $groupDept -Members $sam -ErrorAction SilentlyContinue
            Write-Action "Creado: $sam (pwd: $pwd)"
        }
    }
}

function Setup-TransversalGroups { param([string]$RootOU)
    function GetFirstUser($dept){ Get-ADUser -SearchBase "OU=$dept,OU=Trabajadores,$RootOU" -Filter * -ResultSetSize 1 -ErrorAction SilentlyContinue }
    $mapping = @{}
    $mapping['SG_Comite_Direccion'] = @(); foreach($d in @("Alcaldia","Secretaria","Intervencion","Tesoreria","TIC")){ $u=GetFirstUser $d; if($u){ $mapping['SG_Comite_Direccion'] += $u } }
    $mapping['SG_Proyecto_SmartTown'] = @(); foreach($d in @("Urbanismo","TIC","ServiciosMunicipales")){ $u=GetFirstUser $d; if($u){ $mapping['SG_Proyecto_SmartTown'] += $u } }
    $mapping['SG_Prevencion_Riesgos'] = @(); foreach($d in @("RecursosHumanos","Policia","ServiciosMunicipales")){ $u=GetFirstUser $d; if($u){ $mapping['SG_Prevencion_Riesgos'] += $u } }
    $mapping['SG_Incidencias_TIC'] = @(); foreach($d in @("TIC")){ $u=GetFirstUser $d; if($u){ $mapping['SG_Incidencias_TIC'] += $u } }
    $mapping['SG_Control_Acceso_Policia'] = @(); foreach($d in @("Policia","TIC")){ $u=GetFirstUser $d; if($u){ $mapping['SG_Control_Acceso_Policia'] += $u } }
    foreach($k in $mapping.Keys){ foreach($member in $mapping[$k]){ if($DryRun){ Write-Host "[DRYRUN] Añadir $($member.SamAccountName) a $k" -ForegroundColor Yellow } else { try { Add-ADGroupMember -Identity $k -Members $member.SamAccountName -ErrorAction Stop; Write-Action "Añadido $($member.SamAccountName) -> $k" } catch { Write-Warning "Fallo añadir $($member.SamAccountName) a $k: $($_.Exception.Message)" } } } }
}

function Get-AytoLabReport { param([string]$RootOU)
    Write-Host "=== Reporte Laboratorio Ayuntamiento (5 usuarios) ===" -ForegroundColor Green
    foreach($d in $Global:Deptos){
        $deptOU = "OU=$d,OU=Trabajadores,$RootOU"
        $users = Get-ADUser -SearchBase $deptOU -Filter * -ErrorAction SilentlyContinue
        "Depto $d -> Usuarios: $($users.Count)" | Write-Host
    }
    $groupsOU = "OU=Grupos,$RootOU"
    $groups = Get-ADGroup -SearchBase $groupsOU -Filter * -ErrorAction SilentlyContinue
    Write-Host "Total grupos: $($groups.Count)" -ForegroundColor Cyan
    Write-Host "Tag: $AytoLabTag"
}

function Remove-AytoLab { param([string]$RootOUName,[switch]$Force)
    Test-ModuleAD
    $domainDN = (Get-ADDomain).DistinguishedName
    $rootDN = "OU=$RootOUName,$domainDN"
    $exists = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$rootDN)" -ErrorAction SilentlyContinue
    if(-not $exists){ Write-Warning "No existe OU raíz $rootDN"; return }
    if(-not $Force){ $c = Read-Host "¿Confirmar eliminación completa de $rootDN? (Escribe SI)"; if($c -ne 'SI'){ Write-Host "Cancelado"; return } }
    Write-Host "Eliminando entorno..." -ForegroundColor Red
    $groupsOU = "OU=Grupos,$rootDN"
    Get-ADGroup -SearchBase $groupsOU -Filter * -ErrorAction SilentlyContinue | ForEach-Object { Remove-ADGroup -Identity $_ -Confirm:$false -ErrorAction SilentlyContinue }
    foreach($d in $Global:Deptos){ Get-ADUser -SearchBase "OU=$d,OU=Trabajadores,$rootDN" -Filter * -ErrorAction SilentlyContinue | ForEach-Object { Remove-ADUser -Identity $_ -Confirm:$false -ErrorAction SilentlyContinue } }
    Remove-ADOrganizationalUnit -Identity $rootDN -Recursive -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Entorno eliminado" -ForegroundColor Green
}

# Ejecución principal
Test-ModuleAD
$rootDN = Ensure-OUs -RootOU $RootOUName
Ensure-Groups -RootOU $rootDN
New-DeptUsers -RootOU $rootDN -Counts $UserCounts
Setup-TransversalGroups -RootOU $rootDN
Get-AytoLabReport -RootOU $rootDN

# Ejercicios (idénticos a la versión general) disponibles para reutilizar.
<#
Ejercicios sugeridos:
1. Exportar usuarios de Policía a CSV.
2. Resetear contraseña del primer usuario de TIC.
3. Delegación de creación de cuentas en OU=Policia.
4. Añadir nuevo departamento MedioAmbiente con sus usuarios (ajustar script).
5. Mover usuario entre OU Urbanismo y proyecto SmartTown.
6. Generar script de grupo "dinámico" por patrón de nombre.
7. Configurar LogonHours para Policía.
8. Revisar PasswordNeverExpires y ajustar.
9. Aviso de pwdLastSet >30 días.
10. Informe de grupos vacíos y limpieza.
11. Auditoría de SG_Prevencion_Riesgos a JSON.
12. Crear nuevo usuario RecursosHumanos y verificar membresía.
13. Cambiar sufijo UPN ayto.local -> ayto.es.
14. Clonar membresías de SG_Proyecto_SmartTown.
15. Limpieza final con Remove-AytoLab.
#>

# FIN
