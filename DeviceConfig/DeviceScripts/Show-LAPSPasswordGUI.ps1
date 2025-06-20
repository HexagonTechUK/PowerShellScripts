<#
.SYNOPSIS
    Retrieves and displays the LAPS (Local Administrator Password Solution) password for a specified device in a simple Windows Forms UI.

.DESCRIPTION
    This script prompts the user to enter a device name, queries Active Directory for the LAPS password using the `Get-LapsADPassword` cmdlet,
    and presents the password in a graphical user interface with an option to copy it to the clipboard.

.PARAMETER deviceID
    The name of the computer (device) for which to retrieve the LAPS-managed local administrator password.

.NOTES
    File Name : Show-LAPSPasswordGUI.ps1
    Author    : Paul Gosling, Hexagon Technology Consulting
    Created   : 2025-05-08
    Version   : 1.0
    Requires  : Active Directory module, LAPS module, .NET Windows Forms

.OUTPUTS
    Windows Forms popup displaying the LAPS password for the given device.

.EXAMPLE
    .\Show-LAPSPasswordGUI.ps1

    This will:
        - Prompt for a device name
        - Retrieve the LAPS password from Active Directory
        - Display it in a small form with a "Copy to Clipboard" button
#>

# Import the Active Directory and Forms modules
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms

# Prompt the user for input
$deviceID = Read-Host "Please enter the device name"

# Retrieve the LAPS password object
$passwordObject = get-lapsadpassword -identity $deviceID -AsPlainText

# Extract the clear text password from the password object
$password = $passwordObject.Password

# Create a form for displaying the password
$form = New-Object system.Windows.Forms.Form
$form.Text = "LAPS Password"
$form.Width = 400
$form.Height = 150

# Create a label to display the password
$label = New-Object system.Windows.Forms.Label
$label.Text = "Password: $password"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($label)

# Create a button to copy the password
$button = New-Object system.Windows.Forms.Button
$button.Text = "Copy to Clipboard"
$button.Width = 120
$button.Height = 30
$button.Location = New-Object System.Drawing.Point(10, 50)
$form.Controls.Add($button)

# Add an event handler to the button to copy the password to the clipboard
$button.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($password)
    [System.Windows.Forms.MessageBox]::Show("Password copied to clipboard.")
})

# Show the form
$form.ShowDialog()

# End of script