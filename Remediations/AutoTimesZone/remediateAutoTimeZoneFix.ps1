# This script ensures the tzautoupdate service is running and set to automatic start

# Function to check if a service exists and retrieve its status
function Get-ServiceStatus {
    param (
        [string]$serviceName
    )
    
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        return $service
    } catch {
        Write-Output "Service '$serviceName' does not exist."
        return $null
    }
}

# Define the service name
$serviceName = "tzautoupdate"

# Check if the service exists
$service = Get-ServiceStatus -serviceName $serviceName

if ($service -ne $null) {
    # Ensure the service is set to start automatically
    if ($service.StartType -ne "Automatic") {
        Write-Output "Service '$serviceName' is not set to start automatically. Setting to Automatic..."
        Set-Service -Name $serviceName -StartupType Automatic
    } else {
        Write-Output "Service '$serviceName' is already set to start automatically."
    }
    
    # Check if the service is not running
    if ($service.Status -ne "Running") {
        Write-Output "Attempting to start the service '$serviceName'..."
        try {
            Start-Service -Name $serviceName -ErrorAction Stop
            Write-Output "Service '$serviceName' started successfully."
        } catch {
            Write-Error "Failed to start service '$serviceName': $_"
            # Additional diagnostics
            Write-Output "Attempting to diagnose the issue..."
            
            # Check if the service is disabled
            if ($service.StartType -eq "Disabled") {
                Write-Error "Service '$serviceName' is disabled. Please enable it before attempting to start."
            } else {
                Write-Output "Service '$serviceName' is not disabled."
            }

            # Correct WMI query with proper escaping of the service name
            $serviceWmiName = $serviceName.Replace("\", "\\")  # Escape backslashes if any
            $dependentServices = Get-WmiObject -Query "Select * From Win32_DependentService Where Dependent = 'Win32_Service.Name=\"$serviceWmiName\"'"
            
            if ($dependentServices.Count -gt 0) {
                Write-Output "Service '$serviceName' has dependencies that may not be running:"
                $dependentServices | ForEach-Object {
                    Write-Output " - Dependent service: $($_.Antecedent)"
                }
            } else {
                Write-Output "No dependent services detected for '$serviceName'."
            }
        }
    } else {
        Write-Output "Service '$serviceName' is already running."
    }
} else {
    Write-Error "Cannot proceed because the service '$serviceName' does not exist."
}

# End of script
