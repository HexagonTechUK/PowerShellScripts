<#
.SYNOPSIS
    Exports a list of Intune managed devices using Microsoft Graph API.

.DESCRIPTION
    Authenticates to Microsoft Graph using client credentials and retrieves all Intune managed devices.
    The device details—including name, user ID, sync time, and OS info—are exported to a CSV file for reporting or auditing purposes.

.PARAMETER
    $clientId       : Azure AD Application (Client) ID  
    $clientSecret   : Azure AD Application Secret  
    $tenantId       : Azure AD Tenant ID

.OUTPUTS
    CSV file saved to: C:\ProgramData\_MEM\InTuneManagedDevices.csv

.NOTES
    File Name : Get-IntuneManagedDevices.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-14  
    Version   : 1.0 - Initial script  
    Requires  : Microsoft Graph permissions for deviceManagementManagedDevices.Read.All (App only)

.EXAMPLE
    Run with valid Azure AD app credentials:

        PS> .\Export-IntuneManagedDevices.ps1

    Output:
        C:\ProgramData\_MEM\InTuneManagedDevices.csv
#>
    # Set your Azure AD application credentials
    $clientId = ""
    $clientSecret = ""
    $tenantId = ""
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body
    $accessToken = $tokenResponse.access_token
    $baseUrl = "https://graph.microsoft.com/v1.0"
    $exportPath = Join-Path $env:ProgramData "_MEM\InTuneManagedDevices.csv"

    # Construct the body of the request
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    # Define the headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
    }

    # Fetch Intune managed devices from all pages
    $intune_devices = @()
    $url = "$baseUrl/deviceManagement/managedDevices"
    do {
        $response = Invoke-RestMethod -Uri $url -Headers $headers
        $intune_devices += $response.value
        $url = $response.'@odata.nextLink'
    } while ($null -ne $url)

    # Export Intune device details to CSV
    $intune_devices | Select-Object deviceName, userId, lastSyncDateTime, emailAddress, model, serialNumber, operatingSystem, osVersion, operatingSystemSku |
    Export-Csv -Path $exportPath -NoTypeInformation

# End of script