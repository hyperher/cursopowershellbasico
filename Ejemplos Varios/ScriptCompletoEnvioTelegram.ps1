# Configuración (cambiar estos valores)
$BotToken = "1234567890:ABCdefGhIjKlMnOpQrStUvWxYz"
$ChatID = "@alertasciudad"

# Tu variable con contenido
$MiVariable = "Sistema iniciado correctamente en $env:COMPUTERNAME"

# Enviar a Telegram
$TelegramURL = "https://api.telegram.org/bot$BotToken/sendMessage"
$Body = @{
    chat_id = $ChatID
    text = $MiVariable
}

Invoke-RestMethod -Uri $TelegramURL -Method Post -Body $Body