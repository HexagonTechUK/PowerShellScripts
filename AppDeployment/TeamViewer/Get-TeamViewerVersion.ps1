<#
.SYNOPSIS
    Checks if a specific WinGet package is installed.

.DESCRIPTION
    Uses WinGet to query if a package is present on the system.
    Resolves latest winget executable path if multiple versions exist.

.PARAMETER
    $programName : The WinGet package ID to detect.

.OUTPUTS
    Console output: "$productName v$version installed" if installed, error if WinGet is missing.

.NOTES
    File Name : Get-TeamViewerVersion.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-14  
    Requires  : WinGet, Windows 10/11
#>

$productName = "TeamViewer"   #------------------------------------------------# Application name or function for logfile  
$programName = "TeamViewer.TeamViewer"   #-------------------------------------# WinGet application ID 
$logFileName = Join-Path $env:ProgramData "_MEM\$productName-Version.log"  #---# Path to script logfile   

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

if (!$winget_exe){
    Write-Error "Winget not installed"
}else{
    $wingetPrg_Existing = & $winget_exe list --id $ProgramName --exact --accept-source-agreements
        if ($wingetPrg_Existing -like "*$programName*"){
        $version = (Get-WinGetPackage -Name $productName).InstalledVersion
        Write-Log "$productName v$version installed"
    }
}

# End of script
