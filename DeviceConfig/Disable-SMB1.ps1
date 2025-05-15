<#
.SYNOPSIS
    Disables SMBv1 on client devices.

.DESCRIPTION
   This script checks if SMBv1 protocol is enabled on client devices, 
   and disables any enabled instances.

.EXAMPLE
    .\Disable-SMB1Protocol[Platform].ps1

.NOTES
    File Name : Disable-SMB1.ps1
    Author    : Paul Gosling, Hexagon Tehnology Services
    Last Edit : 2024-07-18
    Version   : 1.0
    Requires  : {Write any requirements or prerequisites for this script}  
.EXAMPLE
    PS> .\Disable-SMB1Protocol.ps1

    Output:
        2025-05-14 12:45 | SMB1 has been disabled.
#>

# Variables (complete these):
$deployType  = "Disable"    #------------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName = "SMB1Protocol-Platform"   #-----------------------------------------# Application name for logfile
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #---# Path to script logfile   

# Create the log file if it doesn't exist
if (-not (Test-Path $logFileName)) {
    New-Item -Path $logFileName -ItemType File -Force
}

# Function to write log messages
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Out-File -FilePath $logFileName -Append
    Write-Output "$timestamp | $Message"
}

function Disable-SMB1 {
    $smb1Status = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
    if ($smb1Status.State -eq 'Enabled') {
        Write-Log "SMB1 is enabled. Disabling SMB1..."
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
        Write-Log "SMB1 has been disabled."
    } else {
        Write-Log "SMB1 is not enabled. No action needed."
    }
}

# Call the function
Disable-SMB1

# End of script
