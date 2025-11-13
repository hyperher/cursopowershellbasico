# Configuración
$BotToken = "TU_BOT_TOKEN_AQUI"
$ChatID = "@alertasciudad"  # o el ID numérico del canal
$Variable = "Contenido de tu variable que quieres enviar"

# URL de la API de Telegram
$TelegramURL = "https://api.telegram.org/bot$BotToken/sendMessage"

# Parámetros del mensaje
$Body = @{
    chat_id = $ChatID
    text = $Variable
    parse_mode = "HTML"  # o "Markdown"
}

# Enviar mensaje
try {
    $Response = Invoke-RestMethod -Uri $TelegramURL -Method Post -Body $Body
    Write-Host "✓ Mensaje enviado correctamente" -ForegroundColor Green
} catch {
    Write-Host "✗ Error enviando mensaje: $($_.Exception.Message)" -ForegroundColor Red
}