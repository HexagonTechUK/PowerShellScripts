# Launch a 64-bit PowerShell script from an Intune Win32 app

# Define the path to the 64-bit PowerShell executable
$PowerShell64Path = Join-Path -Path $env:WINDIR -ChildPath "SysNative\WindowsPowerShell\v1.0\PowerShell.exe"

# Define the full path to the script to be executed
$ScriptToExecute = Join-Path -Path $PSScriptRoot -ChildPath "Install-Wrapper.ps1"

# Prepare the argument list, incorporating the script path
$Arguments = "-File `"$ScriptToExecute`""

# Start the 64-bit PowerShell process with the specified script and arguments
Start-Process -FilePath $PowerShell64Path -ArgumentList $Arguments -Wait -NoNewWindow
