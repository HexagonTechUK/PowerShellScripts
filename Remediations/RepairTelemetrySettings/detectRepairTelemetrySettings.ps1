﻿# Define the path to the registry key
$registryPath = "HKLM:\Software\Policies\Microsoft\Windows\OneDrive"

# Define the name of the registry value
$registryValueName = "DisableFileSyncNGSC"

# Define the expected value
$expectedValue = 0

# Get the current value of the registry key
$currentValue = Get-ItemProperty -Path $registryPath -Name $registryValueName -ErrorAction SilentlyContinue

# Check if the registry key exists and has the correct value
if ($currentValue -ne $null -and $currentValue.$registryValueName -eq $expectedValue) {
    Write-Host "Registry value is set correctly, exit with status code 0"
    exit 0
} else {
    Write-Host "Registry value is not set correctly or does not exist, exit with status code 1"
    exit 1
}
