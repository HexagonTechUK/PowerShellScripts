#region ---------------------------------------------------[Set script requirements]-----------------------------------------------
#Requires -Modules Microsoft.Graph.Authentication
#Requires -Modules Microsoft.Graph.identity.DirectoryManagement
#endregion

#region ---------------------------------------------------[Script Parameters]---------------------------------------------------
#endregion

#region ---------------------------------------------------[Modifiable Parameters and defaults]------------------------------------
# Customizations
[int]$DeviceDisableThreshold = 60        # Number of inactive days to determine a stale device to disable
[int]$DeviceDeleteThreshold  = 90        # Number of inactive days to determine a stale device to delete
[Bool]$TestMode             = $true      # $True = No devices will be deleted, $False = Stale devices will be deleted
[Bool]$Verboselogging       = $True      # $True = Enable verbose logging for t-shoot. $False = Disable Verbose Logging
#endregion

#region ---------------------------------------------------[Set global script settings]--------------------------------------------
Set-StrictMode -Version Latest
#endregion

#region ---------------------------------------------------[Import Modules and Extensions]-----------------------------------------
import-Module Microsoft.Graph.Authentication
import-Module Microsoft.Graph.identity.DirectoryManagement
#endregion

#region ---------------------------------------------------[Static Variables]------------------------------------------------------
[System.Collections.ArrayList]$RequiredScopes = @("Device.ReadWrite.All")
[datetime]$scriptStartTime = Get-Date
[string]$disableDate = "$(($scriptStartTime).AddDays(-$DeviceDisableThreshold).ToString("yyyy-MM-dd"))T00:00:00z"
[string]$deleteDate = "$(($scriptStartTime).AddDays(-$DeviceDeleteThreshold).ToString("yyyy-MM-dd"))T00:00:00z"
if ($Verboselogging){$VerbosePreference = "Continue"}
else{$VerbosePreference = "SilentlyContinue"}
#endregion

#region ---------------------------------------------------[Functions]------------------------------------------------------------
function ConnectTo-MgGraph {
    param ([System.Collections.ArrayList]$RequiredScopes)
    Begin {
        $ErrorActionPreference = 'stop'
    }
    Process {
        try {
            Connect-MgGraph -Scope $RequiredScopes
            Write-verbose "$(Get-Date -Format 'yyyy-MM-dd'),$(Get-Date -format 'HH:mm:ss'),Success to connect to Graph manually"
        } catch {
            Write-Error "$(Get-Date -Format 'yyyy-MM-dd'),$(Get-Date -format 'HH:mm:ss'),Failed to connect to Graph manually, with error: $_"
        }
    }
}
#endregion

#region ---------------------------------------------------[[Script Execution]------------------------------------------------------
$StartTime = Get-Date
$MgGraphAccessToken = ConnectTo-MgGraph -RequiredScopes $RequiredScopes

# Get Pending Devices to disable (Windows devices only)
try {
    $pendingdevices = Get-MgDevice -All -Filter "ApproximateLastSignInDateTime le $($disableDate) AND ApproximateLastSignInDateTime ge $($deleteDate) AND OperatingSystem eq 'Windows'"
    write-verbose "$(Get-Date -Format 'yyyy-MM-dd'),$(Get-Date -format 'HH:mm:ss'),Success to get $($pendingdevices.count) Pending Windows Devices to disable"
} catch {
    write-Error "$(Get-Date -Format 'yyyy-MM-dd'),$(Get-Date -format 'HH:mm:ss'),Failed to get Pending Windows Devices with error: $_"
}

# Get Stale Devices to delete (Windows devices only)
try {
    $staledevices = Get-MgDevice -All -Filter "ApproximateLastSignInDateTime le $($deleteDate) AND OperatingSystem eq 'Windows'"
    write-verbose "$(Get-Date -Format 'yyyy-MM-dd'),$(Get-Date -format 'HH:mm:ss'),Success to get $($staledevices.count) Stale Windows Devices to delete"
} catch {
    write-Error "$(Get-Date -Format 'yyyy-MM-dd'),$(Get-Date -format 'HH:mm:ss'),Failed to get Stale Windows Devices with error: $_"
}

$pendingdevices | Select-Object DeviceId, DisplayName, ProfileType, ApproximateLastSignInDateTime | Sort-Object DisplayName | Export-Csv -Path C:\Admins\pendingDevices.csv -NoTypeInformation
$staledevices   | Select-Object DeviceId, DisplayName, ProfileType, ApproximateLastSignInDateTime | Sort-Object DisplayName | Export-Csv -Path C:\Admins\staleDevices.csv   -NoTypeInformation

# Prepare data for CSV export
$deviceData = @()

# Disable Pending Devices
foreach ($device in $pendingdevices) {
    $deviceData += [pscustomobject]@{
        DeviceName     = $device.DisplayName
        LastSignInDate = $device.ApproximateLastSignInDateTime
        OperatingSystem = $device.OperatingSystem
        Action         = "Disable"
    }

    Write-Output "Device $($device.DisplayName) is pending to be disabled"
}

# Delete Stale Devices
foreach ($device in $staledevices) {
    $deviceData += [pscustomobject]@{
        DeviceName     = $device.DisplayName
        LastSignInDate = $device.ApproximateLastSignInDateTime
        OperatingSystem = $device.OperatingSystem
        Action         = "Delete"
    }

    Write-Output "Device $($device.DisplayName) is stale and will be removed"
}

# Export data to CSV
$csvFilePath = "C:\temp\deviceAudit.csv"
$deviceData | Export-Csv -Path $csvFilePath -NoTypeInformation

[datetime]$scriptEndTime = Get-Date
write-Output "Script execution time: $(($scriptEndTime-$scriptStartTime).ToString('hh\:mm\:ss'))"
write-Output "Device audit saved to: $csvFilePath"
$VerbosePreference = "SilentlyContinue"
#endregion
