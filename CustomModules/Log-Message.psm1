<#
.SYNOPSIS
    PowerShell script to define a reusable Log-Message function for application deployments.

.DESCRIPTION
    This script sets up a logging function that writes timestamped messages to both a log file
    and the console. The console output is visible in Intune logs, making it useful for remote
    monitoring and troubleshooting. The log file is created if it doesn't already exist and 
    supports deployment scenarios such as Install, Upgrade, or Removal.

.EXAMPLE
    Log-Message "Starting upgrade of ContosoApp"
    # Output: 2025-05-06 09:23 | Starting upgrade of ContosoApp

.NOTES
    Log file location: C:\ProgramData\_MEM\Log.log

    When deployed via Intune, messages are also visible in the Intune Management Extension logs
    under 'Device install status' -> 'Output'. This helps with troubleshooting app deployments
    across devices.

.AUTHOR
    Paul Gosling, Hexagon Technology Services

.VERSION
    1.0
#>

# Define log file path
$logFileName = Join-Path $env:ProgramData "_MEM\Log.log"

# Create the log file if it doesn't exist
if (-not (Test-Path $logFileName)) {
    New-Item -Path $logFileName -ItemType File -Force
}

# Function to log messages (to both file and Intune output)
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Out-File -FilePath $logFileName -Append
    Write-Output "$timestamp | $Message"
}

# End of script