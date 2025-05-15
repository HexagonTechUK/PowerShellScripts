<#
.SYNOPSIS
    Automates installation of AZ modules, connects to Azure and dowloads files from the storage container.

.DESCRIPTION
    This script checks for and installs necessary PowerShell modules required for interacting with Azure services. It goes on to retrieve
    files from the Azure storage container and downloads them to the local system.

.EXAMPLE
    .\Set-ScreensaverSlideshow[Remediation].ps1

.NOTES
    Author: Paul Gosling, Hexagon Technology Services
    Last Edit: 2025-02-12
    Version: 1.3
#>

# Define Variables (complete these)

$deployType  = "remediate" # Deployment type: Install, Upgrade, Removal
$productName = "ScreensaverSlideshow" # Application name for logfile and installation
$destFolder = "C:\ProgramData\_MEM\Screensavers"
$storageAccountName = ""
$resourceGroupName = ""
$containerName = ""
$blobPrefix = ""
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

<# Check if NuGet is installed, if not, install it
Register-PackageSource -Name NuGet.org -Location https://www.nuget.org/api/v2/ -ProviderName NuGet -Trusted -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Define required modules
$requiredModules = @("Az.Accounts", "Az.Storage", "AzureAD")

# Install required modules if not already installed
foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Install-Module -Name $module -Force -Confirm:$false -Scope AllUsers
        Import-Module -Name $module -Force
    }
}#>

# Connect to Azure
Connect-AzAccount -ServicePrincipal -TenantId $tenantId -SubscriptionID $subscriptionID -Credential $credential

# Create destination folder if it doesn't exist
if (-not (Test-Path $destFolder)) {
    New-Item -ItemType Directory -Path $destFolder -Verbose
}

# Get storage context
$context = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -Verbose |
           Select-Object -ExpandProperty Context

# Function to update screensavers
function UpdateScreensavers {
    # Delete the Screensavers folder and recreate a new one.
    Remove-Item -Path $destFolder -Recurse -Force -Verbose
    New-Item -ItemType Directory -Path $destFolder -Verbose
    
    # Get list of blobs
    $blobs = Get-AzStorageBlob -Container $containerName -Context $context -Prefix $blobPrefix

    # Process each blob
    foreach ($blob in $blobs) {
        $blobName = $blob.Name.Substring($blob.Name.LastIndexOf('/') + 1)

        # Download the blob
        $localFilePath = Join-Path -Path $destFolder -ChildPath $blobName
        Get-AzStorageBlobContent -Blob $blob.Name -Container $containerName -Context $context -Destination $localFilePath -Verbose
        Write-Log "Downloaded: $blobName"        
    }
}

# Call the function to update screensavers
UpdateScreensavers

# End of script
