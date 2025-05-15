<#
.SYNOPSIS
    Reports on enabled Azure AD users who have Microsoft 365 licenses assigned.

.DESCRIPTION
    This script connects to Azure Active Directory using the AzureAD module,
    identifies all enabled user accounts, checks for any assigned licenses,
    maps license SKU IDs to friendly names, and exports the results to a CSV file.
    It also logs activity to a local logfile.

.PARAMETER 
    A label used to identify the deployment type in the log file name.

.OUTPUTS
    CSV file saved to: C:\ProgramData\_MEM\EnabledUsersWithLicenses.csv
    Log file saved to: C:\ProgramData\_MEM\EnabledLicensedAccount-Status.log

.NOTES
    File Name : Get-EnabledAccountsWithLicense.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-08  
    Version   : 1.0 - Initial Script  
     Requires :   

.EXAMPLE
    Run the script as-is:
        .\Get-EnabledUsersWithLicenses.ps1
#>

# Variables (complete these):
$deployType  = "EnabledAccount"
$productName = "Status"
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"
$outputCsv   = Join-Path $env:ProgramData "_MEM\EnabledUsersWithLicenses.csv"
$results     = @()

# Create log file if needed
if (-not (Test-Path $logFileName)) { New-Item -Path $logFileName -ItemType File -Force }

function Write-Log {
    param ([string]$Message)
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Tee-Object -FilePath $logFileName -Append
}

# Ensure Microsoft Graph module is available
if (-not (Get-Module | Where-Object { $_.Name -like '*Microsoft.Graph*' })) {
    Write-Log "Installing Microsoft Graph module."
    try {
        Install-Module -Name Microsoft.Graph -Force -Scope CurrentUser -ErrorAction Stop
        Write-Log "Microsoft Graph module installed, check logfile."
    } catch {
        Write-Log "Failed to install Microsoft Graph: $_"
        exit
    }
}

# Connect to Microsoft Graph
Connect-AzureAD

# Define a hashtable for mapping SKU IDs to license names
$licenseMap = @{
    "c5928f49-12ba-48f7-ada3-0d743a3601d5" = "Visio Online Plan 2"
    "1f2f344a-700d-42c9-9427-5cea1d5d7ba6" = "Microsoft Stream"
    "4a51bf65-409c-4a91-b845-1121b571cc9d" = "Power Automate per User Plan"
    "639dec6b-bb19-468b-871c-c5c441c4b0cb" = "Microsoft 365 Copilot"
    "6470687e-a428-4b7a-bef2-8a291ad947c9" = "Windows Store"
    "bf666882-9c9b-4b2e-aa2f-4789b0a52ba2" = "PowerApps per App Plan for Information Workers"
    "f30db892-07e9-47e9-837c-80727f46fd3d" = "Microsoft Flow Free"
    "726a0894-2c77-4d65-99da-9775ef05aad1" = "Microsoft Business Center"
    "67ffe999-d9ca-49e1-9d2c-03fb28aa7a48" = "Microsoft 365 F5 Security Add-on"
    "7b26f5ab-a763-4c00-a1ac-f6c4b5506945" = "Power BI Premium P1 Add-on"
    "dcb1a3ae-b33f-4487-846a-a640262fadf4" = "PowerApps Viral"
    "4b9405b0-7788-4568-add1-99614e613b69" = "Exchange Online Plan 2"
    "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235" = "Power BI Pro"
    "061f9ace-7d42-4136-88ac-31dc755f143f" = "Microsoft Intune"
    "38b434d2-a15e-4cde-9a98-e737c75623e1" = "Visio Plan 2"
    "c1d032e0-5619-4761-9b5c-75b6831e1711" = "Power BI Premium Per User"
    "06ebc4ee-1bb5-47dd-8120-11324bc54e06" = "Microsoft 365 E5"
    "ed01faf2-1d88-4947-ae91-45ca18703a96" = "OneDrive for Business"
    "3f9f06f5-3c31-472c-985f-62d9c10ec167" = "Power Pages Trial for Makers"
    "3ab6abff-666f-4424-bfb7-f0bc274ec7bc" = "Microsoft Teams Essentials"
    "50f60901-3181-4b75-8a2c-4c8e4c1d5a72" = "Microsoft 365 F1 for Frontline Workers"
    "078d2b04-f1bd-4111-bbd4-b4b1b354cef4" = "Azure Active Directory Premium"
    "555af716-7534-4f72-a79c-d5a421dd3c5c" = "Microsoft Entra Private Access Premium"
    "53818b1b-4a27-454b-8896-0dba576410e6" = "Microsoft Project Professional"
    "96d2951e-cb42-4481-9d6d-cad3baac177e" = "Cloud PC Enterprise"
    "19ec0d23-8335-4cbd-94ac-6050e30712fa" = "Exchange Online Plan 2"
    "66b55226-6b4f-492c-910c-a3b7a3c9d993" = "Microsoft 365 F3"
    "52ea0e27-ae73-4983-a08f-13561ebdb823" = "Microsoft Teams Premium"
    "6a4a1628-9b9a-424d-bed5-4118f0ede3fd" = "Project Madeira Preview"
    "b4d7b828-e8dc-4518-91f9-e123ae48440d" = "PowerApps per App Plan"
    "4cde982a-ede4-4409-9ae6-b003453c8ea6" = "Microsoft Teams Rooms Pro"
    "5b631642-bd26-49fe-bd20-1daaa972ef80" = "PowerApps Developer Plan"
    "46102f44-d912-47e7-b0ca-1bd7b70ada3b" = "Project Plan 3"

    # Add other mappings here as needed
}

# Get disabled users with licenses
$enabledUsers = Get-AzureADUser -All $true | Where-Object { $_.AccountEnabled -and $_.AssignedLicenses.Count -gt 0 }

# Process users
foreach ($user in $enabledUsers) {
    $licenses = $user.AssignedLicenses | ForEach-Object {
        $skuId = $_.SkuId.ToString()
        $licenseMap[$skuId] ?? "Unknown License (SkuId: $skuId)"
    }

    $results += [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        AssignedLicenses  = $licenses -join ", "
    }
}

# Output
$results | Export-Csv -Path $outputCsv -NoTypeInformation
$results | Format-Table -AutoSize

# End of script