# -----------------------------------------------------------
# Script completo para habilitar auditoría y monitorizar en tiempo real
# eventos de usuario añadido al grupo "Administradores" local
# -----------------------------------------------------------

# Función para habilitar auditoría de administración de cuentas
function Enable-AccountManagementAudit {
    Write-Host "Habilitando auditoría de administración de cuentas (éxito y error)..."

    # Importar módulo para seguridad local si es necesario
    Import-Module SecurityPolicy -ErrorAction SilentlyContinue

    # Definir la configuración para auditoría (éxito y error)
    $AuditCategory = "Account Management"

    # Establecer auditoría para éxito y error en administración de cuentas
    auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable | Out-Null
    auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable | Out-Null

    Write-Host "Auditoría habilitada."
}

# Función para crear y registrar watcher de eventos en Security log
function Start-SecurityEventWatcher {

    Write-Host "Iniciando monitorización de eventos..."

    # Query XML para filtrar eventos 4732 (usuario añadido a grupo local)
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4732)]]</Select>
  </Query>
</QueryList>
"@

    # Crear el watcher
    $global:watcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher (New-Object System.Diagnostics.Eventing.Reader.EventLogQuery("Security",[System.Diagnostics.Eventing.Reader.PathType]::LogName,$query))

    # Registrar el evento para manejar nuevas entradas
    Register-ObjectEvent -InputObject $global:watcher -EventName EventRecordWritten -SourceIdentifier SecurityEventReceived -Action {
        $event = $Event.SourceEventArgs.EventRecord
        if ($event) {
            $message = $event.FormatDescription()
            $time = $event.TimeCreated

            # Buscar si el grupo afectado es "Administradores" (ajustar nombre si es necesario)
            # El mensaje suele contener el grupo y el usuario añadido.
            if ($message -match "Administradores") {
                Write-Host "------------------------------------------"
                Write-Host "¡Evento detectado: usuario añadido a grupo Administradores!"
                Write-Host "Fecha y hora: $time"
                Write-Host "Detalles:"
                Write-Host $message
                Write-Host "------------------------------------------"
            }
        }
    }

    # Activar el watcher
    $global:watcher.Enabled = $true

    Write-Host "Monitorización activa. Presiona Ctrl+C para detener."
}

# -----------------------------------------------------------
# EJECUCIÓN DEL SCRIPT
# -----------------------------------------------------------

# 1. Habilitar auditoría (necesita permisos de administrador)
Enable-AccountManagementAudit

# 2. Iniciar monitorización de eventos
Start-SecurityEventWatcher

# Mantener el script corriendo para escuchar eventos
try {
    while ($true) {
        Start-Sleep -Seconds 5
    }
}
catch {
    Write-Host "Monitorización detenida."
    # Deshabilitar watcher al salir
    if ($global:watcher) {
        $global:watcher.Enabled = $false
        Unregister-Event -SourceIdentifier SecurityEventReceived
        $global:watcher.Dispose()
    }
}
