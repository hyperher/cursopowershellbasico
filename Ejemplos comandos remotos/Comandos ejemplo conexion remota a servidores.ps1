
# ------------------------------
# 1. Establecer sesión remota en un servidor
# ------------------------------
$cred = Get-Credential
Enter-PSSession -ComputerName SERVIDOR01 -Credential $cred

# ------------------------------
# 2. Ejecutar comando remoto para obtener espacio en disco
# ------------------------------
Invoke-Command -ComputerName SERVIDOR01 -ScriptBlock {
    Get-PSDrive -Name C
}

# ------------------------------
# 3. Reiniciar un servicio remoto
# ------------------------------
$servers = @("SERVIDOR01", "SERVIDOR02")
Invoke-Command -ComputerName $servers -ScriptBlock {
    Restart-Service -Name Spooler -Force
}

# ------------------------------
# 4. Copiar un archivo a un servidor remoto
# ------------------------------
Copy-Item -Path ".\script.ps1" -Destination "\\SERVIDOR01\C$\Scripts\" -Force

# ------------------------------
# 5. Comprobar estado de un servicio en varios servidores
# ------------------------------
$servers = @("SERVIDOR01", "SERVIDOR02", "SERVIDOR03")
Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Service -Name w32time
} | Select-Object PSComputerName, Status

# ------------------------------
# 6. Actualizar software remotamente (instalador silencioso)
# ------------------------------
$servers = @("SERVIDOR01", "SERVIDOR02", "SERVIDOR03")
Invoke-Command -ComputerName $servers -ScriptBlock {
    Start-Process msiexec.exe -ArgumentList "/i C:\Instaladores\app.msi /quiet /norestart" -Wait
}

# ------------------------------
# 7. Recopilar información de eventos del sistema
# ------------------------------
Invoke-Command -ComputerName SERVIDOR01 -ScriptBlock {
    Get-EventLog -LogName System -Newest 10
}

# ------------------------------
# 8. Crear un usuario local en servidor remoto
# ------------------------------
$servers = @("SERVIDOR01", "SERVIDOR02", "SERVIDOR03")
Invoke-Command -ComputerName $servers -ScriptBlock {
    net user tempadmin P@ssw0rd123! /add
    net localgroup administrators tempadmin /add
}

# ------------------------------
# 9. Reiniciar servidores remotamente
# ------------------------------
$servers = @("SERVIDOR01", "SERVIDOR02", "SERVIDOR03")
Restart-Computer -ComputerName $servers -Force -Wait

# ------------------------------
# 10. Monitorizar uso de CPU y memoria en servidores
# ------------------------------
$servers = @("SERVIDOR01", "SERVIDOR02", "SERVIDOR03")
Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-Counter '\Processor(_Total)\% Processor Time', '\Memory\Available MBytes'
}