<#
.SYNOPSIS
    Ensures specific registry properties for screensaver settings are present and correctly configured.

.DESCRIPTION
    This script defines and uses a function to check if specific registry keys and values exist under a given path.
    If the registry path does not exist, it is created. Then, it sets the following screensaver-related properties:
    - EncryptedPIDL (sets the screensaver path to C:\ProgramData\_MEM\Screensavers)
    - Shuffle (enables image shuffle)
    - Speed (sets screensaver speed to slow)

.NOTES
	File Name : Set-ScreenSaverPath.ps1 
    Author    : Paul Gosling, Hexagon Technology Services
    Last Edit : 2024-04-19
    Version   : 1.0
#>

# Set working directory to script root
Set-Location -Path $PSScriptRoot

# Variables
$productName = "EncryptedPIDL-Platform"
$RegistryPath = "HKCU:\Software\Microsoft\Windows Photo Viewer\Slideshow\Screensaver"

# Function to set registry property if it doesn't exist
function Set-RegistryPropertyIfNotExist {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )

    if (-not (Test-Path $Path)) {
        # If the registry path doesn't exist, create it
        New-Item -Path $Path -Force | Out-Null
    }

    # Set the registry property
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
}

# Set Encrypted path to file location if it doesn't exist
Set-RegistryPropertyIfNotExist -Path $RegistryPath -Name 'EncryptedPIDL' -Value
"FAAfUOBP0CDqOmkQotgIACswMJ0ZAC9DOlwAAAAAAAAAAAAAAAAAAAAAAAAAYAAx
AAAAAACuWvZJEiBQUk9HUkF+MwAASAAJAAQA776BWEQ7r1pORS4AAABWQAsAAAAG
AAAAAAAAAAAAAAAAAAAARBgGAFAAcgBvAGcAcgBhAG0ARABhAHQAYQAAABgATgAx
AAAAAACuWnqrECBfTUVNAAA6AAkABADvvpdaC5yvWllKLgAAAGabDAAAAAwAAAAA
AAAAAAAAAAAAAABqebYAXwBNAEUATQAAABQAYgAxAAAAAACvWnpKECBTQ1JFRU5+
MQAASgAJAAQA776uWlurr1p6Si4AAABVYwAAAAAKAAAAAAAAAAAAAAAAAAAA4b8T
AFMAYwByAGUAZQBuAHMAYQB2AGUAcgBzAAAAGAAAAA=="

# Turn on the screensaver shuffle pattern if it doesn't exist
Set-RegistryPropertyIfNotExist -Path $RegistryPath -Name 'Shuffle' -Value 1

# Set the screensaver speed to slow if it doesn't exist
Set-RegistryPropertyIfNotExist -Path $RegistryPath -Name 'Speed' -Value 0
    
# End of script