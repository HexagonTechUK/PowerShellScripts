<#
.SYNOPSIS
    Checks BitLocker status and encryption percentage on all drives.

.DESCRIPTION
    This script retrieves all BitLocker volumes and verifies that each is protected 
    and fully encrypted (100%). It logs the status to a defined log file and outputs 
    results suitable for use in Intune detection or remediation scenarios.

.PARAMETER 
    Specifies the type of deployment. Example: "BitLocker"

.OUTPUTS
    Writes detailed drive encryption information to a log file and outputs to console.

.NOTES
    File Name : Get-BitLockerStatus.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-08  
    Version   : 1.0 - Initial Script  
     Requires : PowerShell 5.1+, BitLocker feature enabled, administrative privileges

.EXAMPLE
    Run script via Intune or locally:
    .\Get-BitLockerStatus.ps1
#>

# Variables (complete these):
$deployType  = "BitLocker"    #----------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName = "Status"   #--------------------------------------------------------# Application name or function for logfile   
$drives      = Get-BitLockerVolume   #---------------------------------------------# List BitLocker volumes
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

foreach ($drive in $drives) {
    Write-Log "Drive: $($drive.MountPoint)"
    Write-Log "Protection Status: $($drive.ProtectionStatus)"
    Write-Log "Encryption Percentage: $($drive.EncryptionPercentage)%"
    Write-Log "--------------------------------------"

    # Check if protection status is not "On" (1) or encryption is less than 100%
    if ($drive.ProtectionStatus -ne 1 -or $drive.EncryptionPercentage -lt 100) {
        $allDrivesSecure = $false
    }
}

# If all drives are protected and fully encrypted, exit with 0, else exit with 1
if ($allDrivesSecure) {
    Write-Log "All drives are protected and fully encrypted with BitLocker."
    exit 0
  } else {
    Write-Log "One or more drives are either not protected or not fully encrypted."
	exit 1
}

# End of script