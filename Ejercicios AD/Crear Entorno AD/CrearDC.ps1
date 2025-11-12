rename-computer -ComputerName DC1 -Force
restart-computer -Force

$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress "192.168.0.1" -PrefixLength 24 -DefaultGateway "192.168.0.254"
Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses "192.168.0.1"



$DomainName = "dominio.local"
$SafeModeAdminPassword = "Abcd123456789" | ConvertTo-SecureString -AsPlainText -Force
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModeAdminPassword -DomainNetbiosName "DOMINIO" -InstallDNS:$true -Force:$true