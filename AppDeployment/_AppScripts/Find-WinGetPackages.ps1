<#
.SYNOPSIS
    Generates an HTML report of available WinGet packages.

.DESCRIPTION
    This script uses `Find-WinGetPackage` to enumerate all discoverable packages via WinGet and exports the results to an HTML file.
    The output includes package ID, name, version, and source. The resulting HTML file is then opened automatically in the default browser.

.PARAMETER
    None.

.OUTPUTS
    HTML file saved to: C:\ProgramData\_MEM\winget-packages.html

.NOTES
    File Name : winget-package-report.ps1  
    Author    : Paul Gosling, Hexagon Technology Consulting  
    Created   : 2025-05-14  
    Version   : 1.0 - Initial Script  
    Requires  : PowerShell 5.1 or later, App Installer with WinGet installed

.EXAMPLE
    No input required. Run the script directly:

    Example output:
    Opens C:\ProgramData\_MEM\winget-packages.html displaying a table of WinGet packages.
#>

# Find WinGet packages
$packages    = Find-WinGetPackage ""
$contentPath = Join-Path $env:ProgramData "_MEM\winget-packages.html"
$html = $packages | ConvertTo-Html -Property Id, Name, Version, Source

# Add a title to the HTML
$html = $html | Out-String
$html = "<html><head><title>WinGet Packages</title></head><body>$html</body></html>"

# Save the HTML to a file
$html | Set-Content -Path $contentPath
Start-Process $contentPath

# End of script
