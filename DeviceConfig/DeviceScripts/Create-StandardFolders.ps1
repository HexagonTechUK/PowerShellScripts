<#
.SYNOPSIS
    Creates a set of standard directories used for MEM and admin tasks.

.DESCRIPTION
    This script ensures the required folder structure exists for configuration, logging, 
    temporary file handling, and screensaver deployment. It creates the following directories:
    - C:\Admins
    - C:\ProgramData\_MEM
    - C:\ProgramData\_MEM\Screensavers
    - C:\Temp

.NOTES
    File Name : Create-StandardFolders.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-14  
    Version   : 1.0 - Initial Script  
    Requires  : {Write any requirements or prerequisites for this script} 

.EXAMPLE
    PS> .\Create-StandardFolders.ps1

    Creates the specified directories if they do not already exist.
#>

# Variables (complete these):
$deployType  = "Create" #-------------------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName = "StandardFolders"   #-------------------------------------------------# Application name for logfile
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

# Directories to create
$directories = @(
    'C:\Admins',
    'C:\ProgramData\_MEM',
    'C:\ProgramData\_MEM\Screensavers',
    'C:\Temp'
)

# Create directories
foreach ($dir in $directories) {
    New-Item -Path $dir -ItemType Directory -Force
    Write-Log "Created $dir"
}

Write-Log "Standard folders created"

# End of script
