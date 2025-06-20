<#
.SYNOPSIS
    Detects whether a BitLocker recovery key is present for the system drive and logs the result.

.DESCRIPTION
    This script checks the system's BitLocker status by attempting to retrieve the recovery key for the C: drive. 
    It logs the findings to a file located in the ProgramData directory. If a recovery key is present, it logs the key and exits with a success code. 
    If not, it logs the absence and exits with a failure code, which can be used to trigger remediation in a deployment solution like Intune or MECM.
    
    Prerequisites:
    - Must be run with administrative privileges.
    - PowerShell must have access to the `Get-BitLockerVolume` cmdlet (part of the BitLocker module).

.PARAMETER
    None — All variables are defined within the script:
    - $deployType   : Set to "Detect", "Install", "Upgrade", or "Removal"
    - $productName  : Set to a friendly name, e.g., "BitLocker"
    - $logFileName  : Dynamically generated from the above values, saved under ProgramData

.OUTPUTS
    - Log File: C:\ProgramData\_MEM\Detect-BitLocker.log
    - Console output and file log include timestamped messages about the presence or absence of a recovery key.

.NOTES
    File Name : Detect-BitLocker.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-12  
    Version   : 1.0 - Initial Script  
    Requires  : Admin rights, PowerShell 5.1+, BitLocker module enabled on target device

.EXAMPLE
    This script is typically deployed as part of a proactive remediation:

    Example execution:
    - The script checks C: drive.
    - If recovery key is found:
        "2025-05-12 09:32 | Bitlocker recovery key available 123456-789..."
    - If not found:
        "2025-05-12 09:32 | No bitlocker recovery key available starting remediation"

    {$deployType} = "Detect"
    {$productName} = "BitLocker"
#>

# Variables (complete these):
$deployType  = "Detect"    #-------------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName = "BitLocker"   #-----------------------------------------------------# Application name or function for logfile   
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #---# Path to script logfile   

# Create the log file if it doesn't exist
if (-not (Test-Path $logFileName)) {
    New-Item -Path $logFileName -ItemType File -Force
}

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Out-File -FilePath $logFileName -Append
    Write-Output "$timestamp | $Message"
}

Try {
$Result = (Get-BitLockerVolume -MountPoint C).KeyProtector
$Recoverykey = $result.recoverypassword

If ($recoverykey -ne $null)
{
    Write-Log "Bitlocker recovery key available $Recoverykey "
    exit 0
}
Else
{
    Write-Log "No bitlocker recovery key available starting remediation"
    exit 1
}
}
catch
{
Write-Log "Value Missing"
exit 1
}

# End of script

