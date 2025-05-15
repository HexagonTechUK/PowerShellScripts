<#
.SYNOPSIS
    Retrieves mailbox usage statistics for a list of users and exports the results to a CSV file.

.DESCRIPTION
    This script connects to Exchange Online using the ExchangeOnlineManagement module,
    reads a list of user email addresses from a text file, and retrieves mailbox statistics
    including display name, item count, total size, and last logon time. The results are
    exported to a CSV file for reporting purposes.

.PARAMETER inputFile
    Path to the text file containing one user email address per line.

.PARAMETER outputFile
    Path where the mailbox usage report CSV will be saved.

.NOTES
    File Name : Get-MailboxUsageReport.ps1
    Author    : Paul Gosling, Hexagon Technology Services
    Created   : 2025-05-08
    Version   : 1.0
    Requires  : ExchangeOnlineManagement module  

.OUTPUTS
    CSV file saved to: C:\ProgramData\_MEM\MailboxUsage.csv

.EXAMPLE
    .\Get-MailboxUsageReport.ps1

    This will:
        - Prompt for Exchange Online credentials
        - Read email addresses from C:\ProgramData\_MEM\users.txt
        - Query mailbox statistics for each user
        - Save results to C:\ProgramData\_MEM\MailboxUsage.csv
#>

# Import Exchange Online PowerShell module (Ensure it's installed first)
Import-Module ExchangeOnlineManagement

$credential = Get-Credential
Connect-ExchangeOnline -Credential $credential

# Define the input file with the list of users (user email addresses) and output file
$inputFile  = Join-Path $env:ProgramData "_MEM\users.txt"   # Path to your text file with user emails
$outputFile = Join-Path $env:ProgramData "_MEM\MailboxUsage.csv"  # Path to output CSV file

# Initialize an array to hold mailbox data
$mailboxData = @()

# Read users from the text file
$users = Get-Content -Path $inputFile

# Loop through each user and get mailbox statistics
foreach ($user in $users) {
    try {
        # Get mailbox statistics for the user
        $mailboxStats = Get-MailboxStatistics -Identity $user

        # Create a custom object to store the relevant data
        $mailboxInfo = [PSCustomObject]@{
            User         = $user
            DisplayName  = $mailboxStats.DisplayName
            TotalItemSize = $mailboxStats.TotalItemSize.Value.ToString()
            ItemCount    = $mailboxStats.ItemCount
            LastLogonTime = $mailboxStats.LastLogonTime
        }

        # Add the mailbox info to the array
        $mailboxData += $mailboxInfo
    }
    catch {
        Write-Host "Failed to retrieve data for user: $user" -ForegroundColor Red
    }
}

# Export the mailbox data to a CSV file
$mailboxData | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false

# End of script
