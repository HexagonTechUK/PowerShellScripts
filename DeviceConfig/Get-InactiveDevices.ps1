<#
.SYNOPSIS
    Script to get a list of inactive devices from Active Directory.

.DESCRIPTION
   This PowerShell script retrieves the LastLogonDate information from devices in Active Directory. 
   The exported results will contain the device name, date, and organizational unit path of the object. 
   Adjust the threshold number of days on line 21.

.PARAMETER 
    Get-ADComputer -Server DC -SearchBase OU=Computers

.OUTPUTS
    {Write the output paths for the log file or message logs}

.NOTES
    File Name : Get-InactiveDevices.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-08  
    Version   : 1.0 - Initial Script  
     Requires :  

.EXAMPLE
    "Name, LastLogonDate"
#>

# Variables (complete these):
$thresholdDays = 90
$currentDate = Get-Date
$thresholdDate = $currentDate.AddDays(-$thresholdDays)
$csvFilePath = Join-Path $env:ProgramData "_MEM\InactiveDevices.csv"

$server = "{adsServer}"
$searchbase = "{adsSearchBase}"

# Import the Active Directory module
Import-Module ActiveDirectory

# Retrieve devices from Active Directory that haven't logged in for 90 days or more
$inactiveDevices = Get-ADComputer -Server $server -SearchBase $searchbase -Filter { LastLogonDate -lt $thresholdDate } -Properties LastLogonDate |
    Select-Object Name, @{Name="LastLogonDate"; Expression={$_.LastLogonDate.ToString("yyyy-MM-dd")}}, DistinguishedName

# Export the results to a CSV file
$inactiveDevices | Export-Csv -Path $csvFilePath -NoTypeInformation

# End of script
