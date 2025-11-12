#¿Qué se puede hacer para detectar que un usuario ha sido añadido al grupo de administradores?
#Habilitar auditoría de cambios en grupos locales (incluyendo grupo Administradores).
#Configurar la auditoría de acceso a objetos y cambios en grupos para que se registre un evento cuando un usuario es añadido o eliminado.
#Crear un script que monitorice el log de seguridad para detectar esos eventos específicos.
#Paso 1: Habilitar la auditoría de cambios en grupos
#Esto se suele hacer con la Política de Seguridad Local o mediante GPO:

#Ruta GPO:
#Configuración del equipo > Configuración de Windows > Configuración de seguridad > Directivas locales > Directiva de auditoría > Auditoría de administración de cuentas
#Activar la auditoría para Éxito y Error.


#Paso 3: Script para detectar evento de adición a grupo Administradores en el log de seguridad
#Adaptar nombre de grupo administradores al idioma.

# Definir el filtro de eventos para detectar usuarios añadidos al grupo Administradores local
$filterXML = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
      *[System[(EventID=4732)]]
      and
      *[EventData[Data[@Name='TargetUserName']='Administradores']]
    </Select>
  </Query>
</QueryList>
"@

# Obtener eventos que cumplan el filtro
$events = Get-WinEvent -FilterXml $filterXML

foreach ($event in $events) {
    $timeCreated = $event.TimeCreated
    $message = $event.Message
    Write-Output "Evento detectado a las $timeCreated"
    Write-Output $message
    Write-Output "------------------------------------------"
}

#Paso 4: Paso 4 (Opcional): Crear un watcher que detecte el evento en tiempo real

# Crear un watcher para eventos con ID 4732 en el log Security
$query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4732)]]</Select>
  </Query>
</QueryList>
"@

$watcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher (New-Object System.Diagnostics.Eventing.Reader.EventLogQuery("Security",[System.Diagnostics.Eventing.Reader.PathType]::LogName,$query))

Register-ObjectEvent -InputObject $watcher -EventName EventRecordWritten -Action {
    $event = $Event.SourceEventArgs.EventRecord
    if ($event) {
        $props = $event.Properties
        # Aquí puedes procesar $props para comprobar que se añadió al grupo Administradores
        Write-Host "Se detectó evento 4732: miembro añadido a grupo."
        Write-Host $event.FormatDescription()
    }
}

# Iniciar la escucha
$watcher.Enabled = $true

# Para detenerlo después, usar: $watcher.Enabled = $false

