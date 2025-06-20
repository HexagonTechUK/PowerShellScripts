<#
.SYNOPSIS
    Uninstalls or manages applications using WinGet.

.DESCRIPTION
    Executes one or more WinGet commands to install, upgrade, or remove applications silently.
    Designed for automation via MEM, Intune, or local deployment.

.PARAMETER
    None — application IDs and options are defined within the script.

.OUTPUTS
    Log file saved to: C:\ProgramData\_MEM\Remove-AdobeCreativeCloud.log

.NOTES
    File Name : Remove-AdobeCreativeCloud.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-14  
    Version   : 1.0  
    Requires  : WinGet v1.4+, Windows 10/11, internet access

.EXAMPLE
    Unnstalls AdobeCreativeCloud:
    winget uninstall --id Adobe.CreativeCloud -e --silent
#>

# Variables (complete these):
$deployType  = "Remove"   #--------------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName = "AdobeCreativeCloud"   #-----------------------------------------------------# Application name for logfile
$programName = "Adobe.CreativeCloud"   #-------------------------------------------------------# Deployment type: Install, Upgrade, Removal
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

# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1){
        $winget_exe = $winget_exe[-1].Path
}

if (!$winget_exe){Write-Log "Winget not installed"}

& $winget_exe uninstall --exact --id $programName --silent --accept-source-agreements --scope=machine $param
  Write-Log "$productName successfully removed"

# End of script