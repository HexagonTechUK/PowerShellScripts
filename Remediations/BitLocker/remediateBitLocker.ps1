<#
.SYNOPSIS
    Enforces BitLocker encryption and ensures the recovery key is backed up to Azure AD.

.DESCRIPTION
    This script performs a comprehensive check and remediation for BitLocker on the system drive (C:).
    It logs the current encryption status and performs necessary actions:
    - If encryption is 100%, it logs the recovery key.
    - If encryption is in progress, it resumes BitLocker and backs up the key to Azure AD.
    - If BitLocker is fully encrypted but protection is off, it resumes protection and backs up the key.
    - If not encrypted, it enables BitLocker using XtsAes256 and backs up the key.
    
    Prerequisites:
    - Must be run as Administrator.
    - BitLocker module must be available.
    - Device must be Azure AD joined or Hybrid AAD joined to back up the key using `BackupToAAD-BitLockerKeyProtector`.

.PARAMETER
    - $logFileName : Should be defined before execution, e.g.:
      `$logFileName = "C:\ProgramData\_MEM\Remediate-BitLocker.log"`

.OUTPUTS
    - Log File: User-defined in `$logFileName`, typically under ProgramData.
    - Console output mirrors file log with timestamped entries.

.NOTES
    File Name : Remediate-BitLocker.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-14  
    Version   : 1.0 - Initial Script  
    Requires  : Admin rights, BitLocker module, Azure AD joined machine for key backup

.EXAMPLE
    Example usage in a proactive remediation:

    $logFileName = "C:\ProgramData\_MEM\Enforce-BitLocker.log"

    Example output:
    "2025-05-12 10:15 | Bitlocker recovery key 123456-789..."
    "2025-05-12 10:16 | BitLocker resumed and key backed up"
    "2025-05-12 10:18 | BitLocker enabled and key backed up"

    This script returns:
    - 0 for success
    - 1 for remediation triggered
#>

# Variables (complete these):
$deployType  = "Remediate"    #----------------------------------------------------# Deployment type: Install, Upgrade, Removal   
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

Try 
{
    	$BLinfo = Get-Bitlockervolume
if($BLinfo.EncryptionPercentage -eq '100')
{
    	$Result = (Get-BitLockerVolume -MountPoint C).KeyProtector
    	$Recoverykey = $result.recoverypassword	
    	Write-Log "Bitlocker recovery key $recoverykey"
   	Exit 0
}
if($BLinfo.EncryptionPercentage -ne '100' -and $BLinfo.EncryptionPercentage -ne '0')
{
	Resume-BitLocker -MountPoint "C:"
	$BLV = Get-BitLockerVolume -MountPoint "C:" | select *
	BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
	Exit 1
}
if($BLinfo.VolumeStatus -eq 'FullyEncrypted' -and $BLinfo.ProtectionStatus -eq 'Off')
{
	Resume-BitLocker -MountPoint "C:"
	$BLV = Get-BitLockerVolume -MountPoint "C:" | select *
	BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
	Exit 1
}
if($BLinfo.EncryptionPercentage -eq '0')
{
	Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -SkipHardwareTest -RecoveryPasswordProtector
	$BLV = Get-BitLockerVolume -MountPoint "C:" | select *
	BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
	Exit 1
}
}
catch
{
Write-Log "Value Missing"
	Exit 1
}

# End of script