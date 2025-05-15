<#
.SYNOPSIS
    Validates the presence and correctness of a specific ODBC DSN registry configuration.

.DESCRIPTION
    This script checks whether the registry key 'HKLM:\SOFTWARE\ODBC\ODBC.INI\{dnsName}' exists,
    and verifies that the 'Database' value matches a specified expected DSN name.
    It is useful for confirming that an ODBC data source has been configured correctly
    on the system.

.PARAMETER dsnName
    The expected value for the 'Database' registry entry under the specified ODBC key.

.OUTPUTS
    String messages indicating whether the ODBC values are present or missing.

.NOTES
    File Name : Get-OdbcDsn.ps1
    Author    : Paul Gosling, Hexagon Technology Services
    Created   : 2025-05-06
    Version   : 1.0
    Requires  : PowerShell 5.1 or later, appropriate registry access permissions.

.EXAMPLE
    Run the script after replacing {dsnName} with the expected DSN value:
    $dbValueName = "MyDataSource"

    Example output:
    "ODBC values present" or "ODBC values missing"
#>

# Define the registry path and value name
$regPath = "HKLM:\SOFTWARE\ODBC\ODBC.INI\Partner"
$regValueName = "Database"
$dbValueName  = "{dsnName}"

# Check if the registry key exists
if (Test-Path $regPath) {
    # Get the value of the "Database" registry key
    $dbValue = Get-ItemProperty -Path $regPath -Name $regValueName

    # Check if the value is present
    if ($dbValue.$regValueName -ieq "$dbValueName") {
        # Return exit code 0 if the value is $dbValueName
        Write-Output "ODBC values present"
        #exit 0
    } else {
        # Return exit code 1 if the value is not $dbValueName
        Write-Output "ODBC values missing"
        #exit 1
    }
} else {
    # Return exit code 1 if the registry key does not exist
    Write-Output "ODBC values missing"
    #exit 1
}

# End of script
