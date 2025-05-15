<#
.SYNOPSIS
    Logs the current computer name to a log file.

.DESCRIPTION
    Uses a custom Write-Log function to record the local machine name (from $env:computername)
    to a timestamped log file for auditing or diagnostic purposes.

.OUTPUTS
    PS> Write-Log $env:computername

.NOTES
    File Name : Get-HostName.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-14  
    Version   : 1.0 - Initial version  
    Requires  : PowerShell 5.1 or later

.EXAMPLE
    PS> .\Write-LogMessage.ps1

    Output:
        2025-05-14 12:45 | DEVICE123
#>


# Variables (complete these):
$deployType  = "Get"    #----------------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName = "HostName"   #------------------------------------------------------# Application name or function for logfile   
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

Write-Log $env:computername

# End of script
