<#
.SYNOPSIS
    Script to remove Azure AD device registration using `dsregcmd /leave`.

.DESCRIPTION
    This PowerShell script is intended for use with Microsoft Intune or local execution
    to de-register a device from Azure AD. It includes basic logging to a central log file
    under ProgramData and supports different deployment types such as Install, Upgrade, or Removal.

.NOTES
    Filename  : Remove-DeviceRegistration.ps1
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-06  
    Version   : 1.0 - Initial Script
    Requires  : Administrator privileges

.PARAMETER deployType
    Defines the type of deployment operation (e.g., Install, Upgrade, Removal).

.PARAMETER productName
    The name or purpose of the product being logged (e.g., HostName).

.EXAMPLE
    Run manually:
        .\Remove-DeviceRegistration.ps1

    Deployed via Intune as a remediation or proactive script.
#>

# Variables (complete these):
$deployType  = "Remove"    #-------------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName = "DeviceRegistration"   #--------------------------------------------# Application name or function for logfile   
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #---# Path to script logfile   

# Create the log file if it doesn't exist
if (-not (Test-Path $logFileName)) {
    New-Item -Path $logFileName -ItemType File -Force
}

# Function to log messages (to both file and Intune output)
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Out-File -FilePath $logFileName -Append
    Write-Output "$timestamp | $Message"
}

Start-Process -FilePath "dsregcmd" -ArgumentList "/leave" -Verb RunAs

# End of script