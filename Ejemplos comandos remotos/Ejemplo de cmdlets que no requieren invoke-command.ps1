#Ejemplo de cmdlets que no requieren invoke-command

# 1. Obtener servicios (ej. servicio w32time) en varios servidores
Get-Service -Name w32time -ComputerName SERVIDOR01, SERVIDOR02, SERVIDOR03

# 2. Obtener información del sistema remoto (equivalente a 'systeminfo')
Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName SERVIDOR01, SERVIDOR02

# 3. Obtener eventos del sistema (eventos recientes del log System)
Get-EventLog -LogName System -Newest 10 -ComputerName SERVIDOR01, SERVIDOR02

# 4. Consultar usuarios locales en servidores remotos
Get-CimInstance -ClassName Win32_UserAccount -ComputerName SERVIDOR01 -Filter "LocalAccount=True"

# 5. Consultar procesos en servidores remotos
Get-Process -ComputerName SERVIDOR01, SERVIDOR02

# 6. Consultar espacio en disco (unidad C:) de servidores remotos
Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" -ComputerName SERVIDOR01, SERVIDOR02

# 7. Comprobar configuración del firewall remoto
Get-NetFirewallProfile -ComputerName SERVIDOR01, SERVIDOR02

# 8. Consultar adaptadores de red remotos
Get-NetAdapter -CimSession (New-CimSession -ComputerName SERVIDOR01)

# 9. Consultar la configuración de la tarjeta de red remota
Get-NetIPAddress -ComputerName SERVIDOR01

# 10. Comprobar el estado del servicio Spooler en servidores remotos
Get-Service -Name Spooler -ComputerName SERVIDOR01, SERVIDOR02
