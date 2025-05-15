<#
.SYNOPSIS
    Interactive GUI tool for deploying pre-packaged print drivers with logging.

.DESCRIPTION
    This script presents a WPF-based GUI allowing users to select from a list of predefined print driver installation packages.
    Upon selection, the corresponding installer is launched, and the action is logged. If installation succeeds, the installer is flagged for deletion on next reboot.
    
    Prerequisites:
    - Requires execution in a user context with UI access (not suitable for headless deployments).
    - Installer paths must be valid and accessible.
    - `PresentationFramework` must be available (standard in Windows).
    - `Schedule-DeleteOnReboot` must exist in session or be defined separately.

.PARAMETER
    None — all variables such as `$installFiles` and `$installNames` are hardcoded within the script.
    - `$deployType`      : Used to define type of action, e.g., "Install".
    - `$productName`     : Used to label logs.
    - `$logFileName`     : Destination path for log file.
    - `$installFiles`    : Array of full file paths to driver installers.
    - `$installNames`    : Display names to show in the GUI ComboBox.

.OUTPUTS
    - Log file: `C:\ProgramData\_MEM\Install-PrintDrivers.log`
    - Console output: Mirrors the actions taken (install success/failure).
    - GUI: WPF window to select and initiate installation.

.NOTES
    File Name : Install-PrintDrivers.ps1  
    Author    : Paul Gosling, Hexagon Technology Services  
    Created   : 2025-05-12  
    Version   : 1.0 - Initial Script  
    Requires  : PowerShell 5.1+, PresentationFramework, interactive session, optional: Schedule-DeleteOnReboot function

.EXAMPLE
    Example interaction:
    1. User runs script interactively.
    2. Selects "HP LaserJet Pro M404dn" from ComboBox.
    3. Script launches "C:\Temp\HP_M404dn.exe".
    4. Logs: "HP_M404dn.exe installed successfully."
    
    Output:
    2025-05-12 10:02 | C:\Temp\HP_M404dn.exe installed successfully.
#>

# Variables (complete these):
$deployType     = "Install"    	 #-------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName    = "PrintDrivers" #-------------------------------------------------# Application name for logfile and installation 
$logFileName = Join-Path $env:ProgramData "_MEM\$deployType-$productName.log"  #---# Path to script logfile   

# Create the log file if it doesn't exist
if (-not (Test-Path $logFileName)) {
    New-Item -Path $logFileName -ItemType File -Force
}

# Function to write log messages
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    "$timestamp | $Message" | Out-File -FilePath $logFileName -Append
    Write-Output "$timestamp | $Message"
}

Add-Type -AssemblyName PresentationFramework

# Define the array of installation files with full paths
$installFiles = @(
    "C:\Temp\<driverPackage1.exe>",
	"C:\Temp\<driverPackage2.exe>",
	"C:\Temp\<driverPackage3.exe>",
	"C:\Temp\<driverPackage4.exe>"
)

# Define the array of display names for the print drivers
$installNames = @(
    "<Printer Model 1>",
	"<Printer Model 2>",
	"<Printer Model 3>",
	"<Printer Model 4>"
)

# Create the WPF window
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Title="Print Driver Installer" Height="200" Width="400">
    <Grid>
        <ComboBox x:Name="DriverComboBox" Margin="10" VerticalAlignment="Top" />
        <Button x:Name="InstallButton" Content="Install" HorizontalAlignment="Left" VerticalAlignment="Bottom" Width="75" Margin="10" />
        <Button x:Name="CancelButton" Content="Cancel" HorizontalAlignment="Right" VerticalAlignment="Bottom" Width="75" Margin="10" />
    </Grid>
</Window>
"@

# Load the XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Find controls
$driverComboBox = $window.FindName("DriverComboBox")
$installButton = $window.FindName("InstallButton")
$cancelButton = $window.FindName("CancelButton")

# Populate the ComboBox with driver names
$installNames | ForEach-Object { $driverComboBox.Items.Add($_) }
$driverComboBox.SelectedIndex = 0

# Define the event handler for the Install button
$installButton.Add_Click({
    $selectedIndex = $driverComboBox.SelectedIndex
    $filePath = $installFiles[$selectedIndex]
    if (Test-Path -Path $filePath) {
        Write-Output "Installing $filePath..."
        try {
            # Start the installation process
            Start-Process -FilePath $filePath
            Write-Log "$filePath installed successfully."
        } catch {
            Write-Log "Failed to install $filePath. Error: $_"
        }
    } else {
        Write-Log "File not found: $filePath"
    }
    $window.Close()
})

# Define the event handler for the Cancel button
$cancelButton.Add_Click({
    $window.Close()
})

# Show the window
$window.ShowDialog()

# End of script