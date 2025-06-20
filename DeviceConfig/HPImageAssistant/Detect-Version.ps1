<#
.SYNOPSIS
	PowerShell script to detect the installation version.

.DESCRIPTION
	
	This script checks the version of the application's installation
	file and reports whether the version matches, indicating success or failure.

.EXAMPLE
    .\Detect-Version.ps1

.NOTES
    Author: Paul Gosling, Hexagon Technology Consulting
    Last Edit: 2025-03-03
    Version: 5.1.7.138
#>

# Variables (complete these):
$productName          = "HPImageAssistant"   #------------------------------------------# Application name for logfile
$executablePath       = "C:\Program Files\HPImageAssistant\HPImageAssistant.exe"   #----# Path for 64-bit application
$expectedBuildVersion = "5.3.1.524"   #-------------------------------------------------# Expected executable build version
$transcriptLog        = Join-Path $env:ProgramData "PH\$productName-Version.log"   #----# Path to transcript logfile

# Start logging
Start-Transcript -Path $transcriptLog -Append

# Check if installation exists.
if (Test-Path $executablePath) {
    $executablePath = $executablePath
} else {
    Write-Output "$productName is not installed in either 32-bit or 64-bit paths"
    Stop-Transcript
    exit 1
}

# Get the file version from the found executable path
$fileVersion = (Get-Item "$executablePath").VersionInfo.FileVersion

# Check if file version is greater than or equal to expected version
if ($fileVersion -ge $expectedBuildVersion) {
    Write-Output "$productName file version $expectedBuildVersion, or higher, was detected."
    Stop-Transcript
    exit 0
} else {
    Write-Output "$productName file version $expectedBuildVersion not detected, reported version is $fileVersion."
    Stop-Transcript
    exit 1
}
