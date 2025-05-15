<#
.SYNOPSIS
	PowerShell script to detect the installation version.

.DESCRIPTION
	
	This script checks the version of the application's installation
	file and reports whether the version matches, indicating success or failure.

.NOTES
    Filename  : Get-TeamViewerVersion.ps1
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
        .\Get-TeamViewerVersion.ps1

    Deployed via Intune as a remediation or proactive script.
#>

# Variables (complete these):
$deployType       = "Get"    #-----------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName      = "TeamViewerVersion"   #----------------------------------------# Application name or function for logfile
$executablePath64 = "C:\Program Files\TeamViewer\TeamViewer.exe"   #---------------# Path for 64-bit application
$executablePath32 = "C:\Program Files (x86)\TeamViewer\TeamViewer.exe"   #---------# Path for 32-bit application
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

#Check for Win32 app
$teamviewer = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*teamviewer*"}
if ($teamviewer) {
    $fileVersion = $teamviewer.Version
} else {
    #No Win32 app found - checking if 64-bit installation exists, if not, check for 32-bit.
    if (Test-Path $executablePath64) {
        $executablePath = $executablePath64
    } elseif (Test-Path $executablePath32) {
        $executablePath = $executablePath32
    } else {
        Write-Log "$productName not installed."    
        exit 0 }
} 

# Get the file version from the found executable path
$fileVersion = (Get-Item "$executablePath").VersionInfo.FileVersion
Write-Log $fileVersion
exit 0

# End of script