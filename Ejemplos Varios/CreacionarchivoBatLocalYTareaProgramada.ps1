$transcriptPath = "C:\Program Files\UEMutil\ShowDesktopicons\enable_desktop.log"
Start-Transcript -Path $transcriptPath -Append

#  create content for desktop_fix.ps1
$script = @'
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue
$userName = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName)
$SID = (New-Object System.Security.Principal.NTAccount($userName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
 
reg.exe add "HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDesktop" /t REG_DWORD /d 0 /f | Out-Host
reg.exe add "HKU\$SID\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 1 /f | Out-Host

# Restart explorer.exe to show the desktop
Start-Sleep -Seconds 8
Stop-Process -Name explorer -Force

'@

# Create desktop_fix.ps1 in C:\ProgramData\IntuneScripts
#$path = $(Join-Path $env:ProgramData IntuneScripts)

$path = "C:\Program Files\UEMutil\ShowDesktopicons"
if (!(Test-Path $path)) {
    New-Item -Path $path -ItemType Directory -Force -Confirm:$false
}
Out-File -FilePath $("C:\Program Files\UEMutil\ShowDesktopicons\desktop_fix.ps1") -Encoding unicode -Force -InputObject $script -Confirm:$false

# Register the script as a scheduled task to run at each logon
$Time = New-ScheduledTaskTrigger -AtLogOn
$User = "SYSTEM"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ex bypass -file `"C:\Program Files\UEMutil\ShowDesktopicons\desktop_fix.ps1`""
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "EnableDesktop" -Trigger $Time -User $User -Action $Action -Settings $settings -Force

# Start the scheduled task
Start-ScheduledTask -TaskName "EnableDesktop"

Stop-Transcript