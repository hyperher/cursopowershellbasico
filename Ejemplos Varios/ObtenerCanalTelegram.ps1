# Primero envía un mensaje al canal manualmente
# Luego ejecuta esto para obtener el chat_id:
$Updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$BotToken/getUpdates"
$Updates.result | Select-Object -ExpandProperty message | Select-Object chat