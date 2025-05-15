<#
.SYNOPSIS
    Uninstalls Adobe Flash Player from the system using known uninstaller file patterns.

.DESCRIPTION
    This script searches specified directories for files matching known Adobe Flash Player uninstaller patterns,
    and executes each one with the appropriate uninstall argument. It logs all activity, including success and failure
    of each uninstall attempt.

.PARAMETER uninstallPath
    The full path to the Flash Player uninstaller executable.

.OUTPUTS
    Log messages detailing each uninstallation attempt and outcome.

.NOTES
    File Name : Remove-FlashPlayer  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-15  
    Version   : 1.0 - Initial Script
	Requires: : run with administrative privileges

.EXAMPLE
    .EXAMPLE
    PS> .\Remove-FlashPlayer.ps1
	
	2025-05-12 10:14 | Adobe Flash Player removal script completed.
#>

# Variables (complete these):
$deployType  = "Remove"    #-------------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName = "FlashPlayer"   #---------------------------------------------------# Application name or function for logfile   
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #---# Path to script logfile

# Define the directories to search for uninstallers
$directories = @(
    "C:\Windows\SysWOW64\Macromed\Flash\",
    "C:\Windows\system32\Macromed\Flash\"
)

# Define the file patterns to search for
$filePatterns = @(
    "FlashUtil32_*_pepper.exe",
    "FlashUtil32_*_Plugin.exe",
    "FlashUtil64_*_pepper.exe",
    "FlashUtil64_*_Plugin.exe"
)

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

# Function to perform the uninstallation
function Uninstall-FlashPlayer {
    param (
        [string]$uninstallPath
    )

    if (Test-Path -Path $uninstallPath) {
        Write-Log "Uninstalling Adobe Flash Player using $uninstallPath"
        try {
            # Execute the uninstaller with the -uninstall argument
            & $uninstallPath -uninstall | Out-Null
            Write-Log "Uninstallation process initiated for $uninstallPath."
        } catch {
            Write-Log "Error during uninstallation at $uninstallPath"
        }
    } else {
        Write-Log "Uninstaller not found at $uninstallPath."
    }
}

# Iterate through each directory and file pattern
foreach ($directory in $directories) {
    foreach ($pattern in $filePatterns) {
        # Search for matching uninstallers
        $uninstallers = Get-ChildItem -Path $directory -Filter $pattern -File
        
        foreach ($uninstaller in $uninstallers) {
            # Perform the uninstallation
            Uninstall-FlashPlayer -uninstallPath $uninstaller.FullName
        }
    }
}

Write-Log "Adobe Flash Player removal script completed."

# End of script


