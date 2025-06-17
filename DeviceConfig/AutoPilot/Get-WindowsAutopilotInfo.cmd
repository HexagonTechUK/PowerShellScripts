@echo off
REM This batch file will execute PowerShell commands as specified
REM Open PowerShell with ExecutionPolicy Bypass and run the commands
PowerShell.exe -ExecutionPolicy Bypass -Command "Install-Script -name Get-WindowsAutopilotInfo -Force"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutopilotInfo -Online"

pause
