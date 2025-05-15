<#
.SYNOPSIS
    Retrieves the TeamViewer ClientID from the registry if installed.

.DESCRIPTION
    This script checks the local machine registry for the presence of a TeamViewer installation by looking
    for the 'ClientID' value under the HKLM:\SOFTWARE\TeamViewer key. If found, it reads the value,
    converts it to a 64-bit unsigned decimal number, and outputs it. If the key does not exist, it reports
    that TeamViewer is not installed.

.NOTES
    File Name : Check-TeamViewerID.ps1
    Author    : Paul Gosling, Hexagon Technology Services
    Created   : 2025-05-06
    Version   : 1.0
    
.EXAMPLE
    PS> .\Get-TeamViewerClientID.ps1
    TeamViewer ClientID : 12345678901234567890

    PS> .\Get-TeamViewerClientID.ps1
    TeamViewer not installed.

.EXIT CODES
    0 - Success, ClientID found and displayed
    1 - TeamViewer not installed or ClientID not found
    2 - Error occurred during execution

#>

# Define registry path and value
$regPath = "HKLM:\SOFTWARE\TeamViewer"
$valueName = "ClientID"

# Optional: Define a log file (uncomment if needed)
$logFile = Join-Path $env:ProgramData "_MEM\TeamViewerClientID.log"

try {
    # Check if the registry key and value exist
    $regValue = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction Stop

    # Convert the hexadecimal value to 64-bit unsigned decimal
    $clientIDHex = $regValue.$valueName
    $clientIDDecimal = [convert]::ToUInt64($clientIDHex.ToString("X"), 16)

    $message = "TeamViewer ClientID : $clientIDDecimal"
    Write-Output $message
    Add-Content -Path $logFile -Value "$((Get-Date).ToString("yyyy-MM-dd HH:mm")) $message"

    Exit 0
}
catch [System.Management.Automation.ItemNotFoundException] {
    $message = "TeamViewer not installed."
    Write-Output $message
    Add-Content -Path $logFile -Value "$((Get-Date).ToString("yyyy-MM-dd HH:mm")) $message"
    Exit 1
}
catch {
    $message = "An error occurred: $_"
    Write-Error $message
    Add-Content -Path $$logFile -Value "$((Get-Date).ToString("yyyy-MM-dd HH:mm")) ERROR: $message"
    Exit 2
}

# End of script