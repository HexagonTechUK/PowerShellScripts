<#
.SYNOPSIS
    Powershell script to uninstall HP Image Assistant
    
.DESCRIPTION
   This PowerShell script uninstalls HP Image Assistant

   Multiple methods are used to attempt uninstall. Where not applicable, these are commented out.

.NOTES
    Author: Paul Gosling, Hexagon Technology Consulting
    Last Edit: 2025-03-03
    Version: 1.0
#>

# Variables (complete these):
$deployType    = "Remove"    #-----------------------------------------------------# Deployment type: Install, Upgrade, Remove
$productName   = "HPImageAssistant"   #--------------------------------------------# Application name for identifying package
$transFileName = Join-Path $env:ProgramData "_MEM\Transcript-$productName.log"  #----# Path to transcript logfile

# Start logging
Start-Transcript -Path $transFileName

Remove-Item -Path "$Env:Programfiles\HPImageAssistant" -Recurse -Force

# Conclude logging
Stop-Transcript
