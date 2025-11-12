

$Time = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday, Friday -At 3:00AM
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\Scripts\EnableDesktop.ps1"
$User = "SYSTEM"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "EnableDesktop" -Trigger $Time -User $User -Action $Action -Settings $Settings -Force
