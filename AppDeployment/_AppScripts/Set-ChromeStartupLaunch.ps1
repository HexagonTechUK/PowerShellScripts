<#
.SYNOPSIS
    Creates a registry key that auto-launches chrome on startup, with the URL in a new tab.

.DESCRIPTION
   {.DESCRIPTION
    This script creates a registry key under the current user's Run path that launches Google Chrome automatically at logon.
    It opens Chrome with a specified URL in a new browser tab. This is typically used to ensure that a particular webpage,
    such as a dashboard, intranet site, or application portal, is immediately visible to the user upon sign-in.

.PARAMETER 
    {Write any parameters or expected values for this script}

.OUTPUTS
    {Write the output paths for the log file or message logs}

.NOTES
    File Name : Set-ChromeStartupLaunch.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-15  
    Version   : 1.0 - Initial Script  

#>

# Define Variables (complete these)
$deployType    = "Set"    #-----------------------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName   = "ChromeStartupLaunch"    #-------------------------------------------------# Application name for installation
$keyPath       = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"    #-----------------# Registry key path
$valueName     = "ChromeStartupLaunch"    #-------------------------------------------------# Registry key value
$chromePath    = Join-Path $env:ProgramFiles "\Google\Chrome\Application\chrome.exe"    #---# Path to Application
$chromeURL     = "https://myURL.com/"    #--------------------------------------------------# URL to load at start up
$chromeArgs    = "--new-window $chromeURL"    #---------------------------------------------# Application arguments
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #------------# Path to script logfile   

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

# Check if registry key exists, create if not
if (!(Test-Path -LiteralPath $keyPath)) {
    New-Item -Path $keyPath -Force -ea SilentlyContinue
}

# Create/update registry value
New-ItemProperty -Path $keyPath -Name $valueName -Value "$chromePath $chromeArgs" -PropertyType String -Force
Write-Log "Machine Startup URL set to 

# End of script