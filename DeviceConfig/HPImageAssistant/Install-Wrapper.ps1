<#
.SYNOPSIS
	Win32App to install HP Image Assistant

.DESCRIPTION
	This PowerShell script installs HP Image Assistant

.EXAMPLE
    .\Install-Wrapper.ps1

.NOTES
    Author: Paul Gosling, Hexagon Technology Consulting
    Last Edit: 2025-02-28
    Version: 5.1.7.138
#>

function Get-LoggedOnUsers {
    [CmdletBinding()]
    param(
        [string]$Server # Target server; defaults to the local machine if not specified
    )

    $header = @('USERNAME', 'SESSIONNAME', 'ID', 'STATE', 'IDLE TIME', 'LOGON TIME')

    try {
        $queryResult = if ($Server) { query user /server:$Server } else { query user }
        $indexes = $header | ForEach-Object { ($queryResult[0]).IndexOf(" $_") }

        # Process each row into a PSObject, skipping the header
        $queryResult[1..($queryResult.Count - 1)] | ForEach-Object {
            $userObj = New-Object -TypeName PSObject
            for ($i = 0; $i -lt $header.Count; $i++) {
                $begin = $indexes[$i]
                $end = if ($i -lt $header.Count - 1) { $indexes[$i + 1] } else { $_.length }
                $userObj | Add-Member -MemberType NoteProperty -Name $header[$i] -Value ($_.Substring($begin, $end - $begin).Trim())
            }
            $userObj
        }
    } catch {
        # Distinguish between no results and a query failure
        if ($_.Exception.Message -ne 'No User exists for *') {
            Write-Error "Error querying users: $($_.Exception.Message)"
        }
    }
}

# Navigate to script's directory
Set-Location -Path $PSScriptRoot

# Retrieve logged-on user information
$userInfo = Get-LoggedOnUsers
$userName = $userInfo.USERNAME
$userProfilePath = Join-Path -Path $env:HOMEDRIVE -ChildPath ("users", $userName) -Resolve
$loggedOnUser = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData\$($userInfo.ID)" -Name LoggedOnUser -ErrorAction SilentlyContinue 


# Variables (complete these):
$deployType     = "Install"    #----------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName    = "HPImageAssistant"   #--------------------------------------------# Application name for logfile
$installCmd     = "hp-hpia-5.3.1.exe"    #------------------------------------------# Installer file from the supplier
$installArgs    = "/s /e /f ""$Env:Programfiles\HPImageAssistant"""    #------------# Installation switches
$transcriptLog  = Join-Path $env:ProgramData "_MEM\Transcript-$productName.log"   #---# Path to transcript logfile

# Start logging
Start-Transcript -Path $transcriptLog -Append

Write-Host "User Profile Path: $userProfilePath"
Write-Host "Logged-on User: $loggedOnUser"

# Suspend BitLocker before installation
Suspend-BitLocker -MountPoint "C:" -RebootCount 1

# Begin installation
Write-Host "Starting installation: $installCmd with arguments $installArgs"
Start-Process $installCmd -ArgumentList $installArgs -Wait

# Conclude logging
Stop-Transcript
