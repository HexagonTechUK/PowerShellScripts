<#
.SYNOPSIS
    Exports the last logon date of all Active Directory computers.

.DESCRIPTION
    Queries Active Directory for all computer objects and extracts each computer's name and last logon timestamp.
    Outputs the data to a CSV file for audit or reporting purposes.

.OUTPUTS
    CSV file saved to: C:\ProgramData\_MEM\LastDeviceLogin.csv

.NOTES
    File Name : Export-ADComputerLastLogon.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-14  
    Version   : 1.0 - Initial script  
    Requires  : ActiveDirectory PowerShell module

.EXAMPLE
    PS> .\Export-ADComputerLastLogon.ps1

    Output:
        C:\ProgramData\_MEM\LastDeviceLogin.csv
#>

# Define the path for the output CSV file
$outputCsv = Join-Path $env:ProgramData "_MEM\LastDeviceLogin.csv"
$computers = Get-ADComputer -Filter * -Property Name, LastLogonDate
$results = @()

# Import the Active Directory module
Import-Module ActiveDirectory

# Loop through each computer object and gather the necessary information
foreach ($computer in $computers) {
    # Create a custom object with the computer name and last logon date
    $result = [PSCustomObject]@{
        ComputerName = $computer.Name
        LastLogonDate = $computer.LastLogonDate
    }
    # Add the custom object to the results array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation

# End of script
