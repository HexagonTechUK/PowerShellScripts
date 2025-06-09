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
Start-Transcript -Path "C:\ProgramData\$intuneTenantName\$env:COMPUTERNAME\dismFix.txt" -Append:$true -Force:$true

# Function to append log
function Write-Log {
    Param ([string]$logMessage)
    Add-Content -Path $logPath -Value $logMessage
}    

Write-Log "Starting SFC scan..."
$sfcOutput = sfc /scannow
Write-Log "SFC repair completed."
    
Write-Log "DISM detected issues, attempting repair..."
$dismRepairOutput = dism /Online /Cleanup-Image /RestoreHealth
Write-Log "DISM repair completed. Output: $($dismRepairOutput)"