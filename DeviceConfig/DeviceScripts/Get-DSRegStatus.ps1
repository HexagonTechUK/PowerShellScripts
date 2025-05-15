<#
.SYNOPSIS
    Captures and saves the output of the `dsregcmd /status` command to a text file.

.DESCRIPTION
    This script runs the `dsregcmd /status` command to check the current device's Azure AD Join status,
    then exports the output to a text file located in the ProgramData directory.

.NOTES
    File Name : Get-DSRegStatus.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-08  
    Version   : 1.0 - Initial Script  
     Requires :  

.OUTPUTS
    Text file saved to: C:\ProgramData\_MEM\dsregcmd_status.txt

.EXAMPLE
    .\Export-DsregStatus.ps1

    This will:
        - Run `dsregcmd /status`
        - Save the output to C:\ProgramData\_MEM\dsregcmd_status.txt
#>

# Run dsregcmd and capture the output
$dsregcmdOutput = dsregcmd /status

# Specify the file path for the output
$outputFilePath = Join-Path -Path $env:ProgramData -ChildPath "_MEM\dsregcmd_status.txt"

# Export the output to the specified file
$dsregcmdOutput | Out-File -FilePath $outputFilePath

# End of script
