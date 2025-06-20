<#
.SYNOPSIS
    Uninstalls all installed versions of Adobe Reader XI from the machine.

.DESCRIPTION
    This script searches for all instances of applications matching the defined program name pattern 
    (e.g., "Adobe Reader XI") using WMI, and attempts to uninstall each one. It logs both the attempt 
    and the result of the uninstall process.

.PARAMETER programName
    The display name pattern of the application to search for (e.g., "Adobe Reader XI").

.OUTPUTS
    Log messages indicating success or failure of each uninstall attempt.

.NOTES
    File Name : Remove-AdobeAcrobatXI.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-15  
    Version   : 1.0 - Initial Script  
    Requires  : {Write any requirements or prerequisites for this script}  

.EXAMPLE
    PS> $programName = "Adobe Reader XI"
    PS> .\Uninstall-AdobeXI.ps1

.NOTES
    Ensure the script is run with administrative privileges. Use of Win32_Product may trigger a reconfiguration of all MSI-installed apps.
#>

# Variables (complete these):
$deployType     = "Remove"      #--------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName    = "AdobeReaderXI"      #-------------------------------------------# Application name for logfile
$programName    = "Adobe Reader XI"      #-----------------------------------------# Application name for WMI query
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

# Function to uninstall all versions of Adobe Reader XI
function Uninstall-Application {
    Write-Log "Searching for all versions of $programName."

    # Get instances of applications that match the pattern
    $apps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "$programName*" }

    if ($apps) {
        foreach ($app in $apps) {
            Write-Log "Found $($app.Name). Attempting to uninstall..."
            $app.Uninstall() | Out-Null

            # Verify if the application was successfully uninstalled
            $appAfterUninstall = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $app.Name }
            if (!$appAfterUninstall) {
                Write-Log "$($app.Name) has been successfully uninstalled."
            } else {
                Write-Log "Failed to uninstall $($app.Name)."
            }
        }
    } else {
        Write-Log "No versions of $appPattern found on this machine."
    }
}

# Run the uninstall function
Uninstall-Application

# End of script
