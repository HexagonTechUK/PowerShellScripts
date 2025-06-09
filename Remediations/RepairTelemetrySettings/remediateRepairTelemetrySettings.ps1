# Define variables
$productname = "Onedrive Fix - detection"

# Function to get Intune tenant name for current user
function Get-IntuneTenantName {
    try {
        # Path to Intune enrollments
        $enrollmentsPath = "HKLM:\\SOFTWARE\\Microsoft\\Enrollments"
        $enrollmentKeys = Get-ChildItem -Path $enrollmentsPath -ErrorAction SilentlyContinue
        foreach ($key in $enrollmentKeys) {
            $upn = (Get-ItemProperty -Path $key.PSPath -Name "UPN" -ErrorAction SilentlyContinue).UPN
            if ($upn) {
                $tenantName = $upn -replace '.*@', ''
                return $tenantName
            }
        }
        Write-Output "Could not find Intune tenant name in registry"
        return $null
    } catch {
        Write-Output "Error getting Intune tenant name: $_"
        return $null
    }
}

# Get and store the tenant name
$intuneTenantName = Get-IntuneTenantName

#Start Transcript logging to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\$Id.txt
Start-Transcript -Path "C:\ProgramData\$intuneTenantName\$env:COMPUTERNAME\installwrapper-$productname.txt" -Append:$true -Force:$true

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