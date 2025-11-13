function Send-TelegramMessage {
    param(
        [string]$Message,
        [string]$BotToken, #= "TU_BOT_TOKEN_AQUI",
        [string]$ChatID #= "@nombrecanal"
    )
    
    $TelegramURL = "https://api.telegram.org/bot$BotToken/sendMessage"
    
    $Body = @{
        chat_id = $ChatID
        text = $Message
        parse_mode = "HTML"
    }
    
    try {
        Invoke-RestMethod -Uri $TelegramURL -Method Post -Body $Body | Out-Null
        return $true
    } catch {
        Write-Error "Error enviando a Telegram: $($_.Exception.Message)"
        return $false
    }
}

# Usar la función
$MiVariable = "¡Alerta! Sistema comprometido a las $(Get-Date)"
Send-TelegramMessage -Message $MiVariable -BotToken "xxxxx" -ChatID "@