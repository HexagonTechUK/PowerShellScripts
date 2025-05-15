<#
.SYNOPSIS
    Queries local registry to return the unistall strings for all installed applications.

.DESCRIPTION
    This script performs a query on the local registry to retrieve the uninstallation strings
	for all applications currently installed on the system, providing a comprehensive list
	of the necessary information for uninstalling each application.

.NOTES
    Script Name: Get-Uninstall-Strings.ps1
    Author: Paul Gosling, Hexagon Technology Services
    Date: 2025-05-08
    Version: 1.0
    Requires: PowerShell 5.1+, BitLocker feature enabled, administrative privileges
#>

$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$csvPath = Join-Path $env:ProgramData "_MEM\Uninstall-AppPaths.csv"

Get-ItemProperty -Path $regPaths |
Where-Object { $_.DisplayName -and $_.DisplayName.Trim() } |
Select-Object DisplayName, DisplayVersion, UninstallString |
Sort-Object DisplayName |
Export-Csv -Path $csvPath -NoTypeInformation

# End of script
