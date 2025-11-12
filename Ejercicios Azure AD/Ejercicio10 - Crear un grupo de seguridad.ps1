#Crear un grupo de seguridad

New-AzureADGroup -DisplayName "Equipo Sistemas" -MailEnabled $false -SecurityEnabled $true -MailNickname "equiposistemas"
