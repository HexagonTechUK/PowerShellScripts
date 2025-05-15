<#
.SYNOPSIS
    Automates installation of AZ modules, connects to Azure and dowloads files from the storage container.

.DESCRIPTION
    This script checks for and installs necessary PowerShell modules required for interacting with Azure services. It goes on to check
    age of files from the Azure storage container and proceed to remediation if they are newer or missing locally. 

.NOTES
    Author: Paul Gosling, Hexagon Technology Services
    Last Edit: 2025-02-12
    Version: 1.3
#>

# Define Variables (complete these)

$deployType  = "detect" # Deployment type: Install, Upgrade, Removal
$productName = "ScreensaverSlideshow" # Application name for logfile and installation
$destFolder = "C:\ProgramData\_MEM\Screensavers"
$storageAccountName = ""
$containerName = ""
$blobPrefix = ""
$dateFile = ""
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #---# Path to script logfile

# Define credentials
$securePassword = ConvertTo-SecureString -String "" -AsPlainText -Force
$tenantId = ''
$subscriptionID = ''
$applicationId = ''
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $securePassword

# Create the log file if it doesn't exist
if (-not (Test-Path $logFileName)) {
    New-Item -Path $logFileName -ItemType File -Force
}

# Function to write log messages
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Out-File -FilePath $logFileName -Append
    Write-Output "$timestamp | $Message"
}

# Set working directory to script root
Set-Location -Path $PSScriptRoot

# Check if NuGet is installed, if not, install it
Register-PackageSource -Name NuGet.org -Location https://www.nuget.org/api/v2/ -ProviderName NuGet -Trusted -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force

# Define required modules
$requiredModules = @("Az.Accounts", "Az.Storage", "AzureAD")

# Install required modules if not already installed
foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Install-Module -Name $module -Force -Confirm:$false -Scope AllUsers
        Import-Module -Name $module -Force
    }
}

# Connect to Azure
Connect-AzAccount -ServicePrincipal -TenantId $tenantId -SubscriptionID $subscriptionID -Credential $credential

# Create destination folder if it doesn't exist
if (-not (Test-Path $destFolder)) {
    New-Item -ItemType Directory -Path $destFolder -Verbose
}
# Function to check and update screensavers
function CheckAndUpdateScreensavers {
    # Get last modified date of remote date.txt
    $remoteFile = (Invoke-WebRequest -Uri "https://$storageAccountName.blob.core.windows.net/$containerName/$blobPrefix$dateFile" -UseBasicParsing).Headers.'Last-Modified'
    $remoteDate = [DateTime]::ParseExact($remoteFile, "ddd, dd MMM yyyy HH:mm:ss 'GMT'", [System.Globalization.CultureInfo]::InvariantCulture).ToLocalTime()

    # Get last modified date of local date.txt
    $localDate = Get-Item "$destFolder\$dateFile" | Select-Object -ExpandProperty LastWriteTime
    
    if ($remoteDate -gt $localDate) {
        # If the remote date is newer than the local date, attempt remediation.
        Write-Log "Newer screensaver found, attempting remediation."
        exit 1
    } else {
        Write-Log "Screensaver is up to date."
        exit 0
    }
}

CheckAndUpdateScreensavers

# End of script
