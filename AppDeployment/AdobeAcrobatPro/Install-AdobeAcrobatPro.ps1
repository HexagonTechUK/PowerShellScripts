<#
.SYNOPSIS
    Installs or manages applications using WinGet.

.DESCRIPTION
    Executes one or more WinGet commands to install, upgrade, or remove applications silently.
    Designed for automation via MEM, Intune, or local deployment.

.PARAMETER
    None — application IDs and options are defined within the script.

.OUTPUTS
    Log file saved to: C:\ProgramData\_MEM\Install-AdobeAcrobatPro.log

.NOTES
    File Name : Install-AdobeAcrobatPro.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-14  
    Version   : 1.0  
    Requires  : WinGet v1.4+, Windows 10/11, internet access

.EXAMPLE
    Installs AdobeAcrobatPro:
    winget install --id Adobe.Acrobat.Pro -e --silent
#>

# Variables (complete these):
$deployType  = "Install"   #-------------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName = "AdobeAcrobatPro"   #-----------------------------------------------# Application name for logfile
$programName = "Adobe.Acrobat.Pro"   #---------------------------------------------# Deployment type: Install, Upgrade, Removal
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

& $winget_exe install --exact --id $ProgramName --silent --accept-package-agreements --accept-source-agreements --scope=machine $param
  $wingetPrg_Existing = & $winget_exe list --id $ProgramName --exact --accept-source-agreements
        if ($wingetPrg_Existing -like "*$programName*"){
        $version = (Get-WinGetPackage -Name "Adobe Acrobat").InstalledVersion
        Write-Log "$productName v$version installed"
        }

# End of script