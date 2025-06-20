<#
.SYNOPSIS
    Retrieves data from InTune, including deviceName and registeredUser.

.DESCRIPTION
   This PowerShell script queries the Intune API to retrieve managed device information.
   It iterates through all pages of device data, if pagination is necessary, and accumulates the results.
   Finally, it exports the retrieved device details, including device names and associated registered users
   to a CSV file for further analysis or reporting.

.NOTES
    File Name : Get-MgDeviceManagementDetectedApp.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-08  
    Version   : 1.0 - Initial Script  
     Requires :

.PARAMETER
    $clientId       : Azure AD Application (Client) ID  
    $clientSecret   : Azure AD Application Secret  
    $tenantId       : Azure AD Tenant ID

.OUTPUTS
    Outputs all detected apps to C:\ProgramData\_MEM\detectedApps.csv
#>

# Variables (complete these):
$clientId     = ""
$clientSecret = ""
$tenantId     = ""
$tokenUrl     = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$csvFilePath  = Join-Path $env:ProgramData "_MEM\detectedApps.csv"

    # Construct the body of the request
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    # Get the OAuth 2.0 access token and extract token from the response
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body
    $accessToken = $tokenResponse.access_token

    # Define the headers with the access token
    $headers = @{
        Authorization = "Bearer $accessToken"
    }

    # Define the base URL for Microsoft Graph API
    $baseUrl = "https://graph.microsoft.com/v1.0"

    # Fetch Intune managed devices from all pages
    $intune_devices = @()
    $url = "$baseUrl/deviceManagement/detectedApps"
    do {
        $response = Invoke-RestMethod -Uri $url -Headers $headers
        $intune_devices += $response.value
        $url = $response.'@odata.nextLink'
    } while ($null -ne $url)

    # Export Intune device details to CSV
    $intune_devices | Select-Object * | Export-Csv -Path $csvFilePath -NoTypeInformation
	
# End of script

