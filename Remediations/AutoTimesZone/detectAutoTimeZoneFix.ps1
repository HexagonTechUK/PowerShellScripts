# Function to check if time service exists
function Get-ServiceStatus {
    param (
        [string]$serviceName
    )
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        return $service
    } catch {
        return $null
    }
}
 
# Define the service name
$serviceName = "tzautoupdate"
 
# Check if the service exists
$service = Get-ServiceStatus -serviceName $serviceName
 
if ($service) {
    # Check if the service is running
    if ($service.Status -ne "Running") {
        Write-Output "Service '$serviceName' is not running. Attempting to start..."
        exit 1
    } else {
        Write-Output "Service '$serviceName' is already running."
        exit 0
    }
}