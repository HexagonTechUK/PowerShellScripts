﻿$productname = "Onedrive Fix - detection"

#Start Transcript in PH folder
$Transcriptlogfilename = $env:ProgramData+"\PH\installwrapper-$productname+.log"
Start-Transcript -Path $Transcriptlogfilename -Append

# Define the path to the registry key
$registryPath = "HKLM:\Software\Policies\Microsoft\Windows\OneDrive"

# Define the name of the registry value
$registryValueName = "DisableFileSyncNGSC"

# Define the value to be set
$registryValue = 0

# Check if the registry path exists
if (-not (Test-Path $registryPath)) {
    # Create the registry path if it does not exist
    New-Item -Path $registryPath -Force
}

# Set the registry value
Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $registryValue -Type DWORD
Get-ItemProperty -Path $registryPath -Name $registryValueName

Stop-Transcript