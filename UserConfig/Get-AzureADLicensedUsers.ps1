<#
.SYNOPSIS
    Identifies enabled Azure AD users who still have licenses assigned and exports the results.

.DESCRIPTION
    This script connects to Microsoft Graph and Azure AD to retrieve a list of enabled users who still have Office 365 licenses assigned.
    It maps license SKU IDs to readable license names using a defined hashtable, compiles the results, and exports them to a CSV file for review.
    
    Prerequisites:
    - The `Microsoft.Graph` PowerShell module must be installed and imported.
    - User must be signed into Azure AD with appropriate permissions to read user and license information.
    - Script must be run in an environment where Microsoft Graph SDK is supported.

.PARAMETER
    None — All configuration and parameters are defined within the script:
    - $licenseMap          : Hashtable mapping SKU GUIDs to readable license names
    - $results             : Collection to store and export the final output
    - Export path          : Hardcoded to `"C:\ProgramData\_MEM\UsersWithLicenses.csv"`

.OUTPUTS
    - CSV file: C:\Admins\UsersWithLicenses.csv — contains display name, UPN, and readable license names
    - Console output: formatted table showing the same data

.NOTES
    File Name : Get-AzureADLicensedUsers.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-12  
    Version   : 1.0 - Initial Script  
    Requires  : Microsoft.Graph module, AzureAD sign-in with delegated directory read permissions

.EXAMPLE
    Example result from output CSV and table:

    DisplayName     UserPrincipalName           AssignedLicenses
    ------------    ------------------------    -------------------------------
    Jane Doe        jane.doe@domain.com         Office 365 Enterprise E3
    John Smith      john.smith@domain.com       Office 365 Enterprise E1, Office 365 Enterprise F1

    Note:
    Run `Install-Module Microsoft.Graph -Scope CurrentUser` beforehand if not already installed.
#>

#Install-Module Microsoft.Graph

# Import the Microsoft Graph module
Import-Module Microsoft.Graph

# Connect to Microsoft Graph
Connect-AzureAD

# Define a hashtable for mapping SKU IDs to license names
$licenseMap = @{
    "c42b9cae-ea4f-4ab7-9717-81576235ccac"	= "Office 365 Enterprise E1"
    "6fd2c87f-b296-42f0-b197-1e91e994b900"	= "Office 365 Enterprise E3"
    "bea4c11e-220a-4e6d-8eb8-8ea15d019f90"	= "Office 365 Enterprise E5"
    "e1b6bf5a-49e7-4efb-bc4b-22163b3a7065"	= "Office 365 Enterprise F1"
}

# Get all users from Azure AD
$allUsers = Get-AzureADUser -All $true
$disabledUsers = $allUsers | Where-Object { $_.AccountEnabled -eq $true }
$outputCsv = Join-Path $env:ProgramData "_MEM\UsersWithLicenses.csv"
$results = @()

# List disabled users who still have licenses
$disabledUsersWithLicenses = $disabledUsers | Where-Object {
    ($_.AssignedLicenses).Count -gt 0
}

# For each user, map the license SKU IDs to their respective names
$disabledUsersWithLicenses | ForEach-Object {
    $userLicenses = @()
    foreach ($assignedLicense in $_.AssignedLicenses) {
        $skuId = $assignedLicense.SkuId.ToString()
        $licenseName = $licenseMap[$skuId]

        if (-not $licenseName) {
            $licenseName = "Unknown License (SkuId: $skuId)"
        }

        $userLicenses += $licenseName
    }

    # Store the result in the results array
    $results += [PSCustomObject]@{
        DisplayName        = $_.DisplayName
        UserPrincipalName  = $_.UserPrincipalName
        AssignedLicenses   = $userLicenses -join ", "
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation

# Display the results in a table format
$results | Format-Table -AutoSize

# End of script