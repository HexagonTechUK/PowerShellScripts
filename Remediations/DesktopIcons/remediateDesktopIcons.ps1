<#
.SYNOPSIS
    Script to deploy desktop icons.

.DESCRIPTION
   This script copies down the desktop icons zip file from an Azure Blob storage container, 
   copies the .ico file to the Windows directory and creates the shortcuts in C:\Users\Public\Desktop

.EXAMPLE
    .\Install-DesktopIcons[Remediation].ps1

.NOTES
    Author: Paul Gosling, Hexagon Technology Consulting
    Last Edit: 2025-02-03
    Version: 1.0
#>

# Define Variables (complete these)
$deployType  = "Install" # Deployment type: Install, Upgrade, Removal
$productName = "DesktopIcons-Remediation" # Application name for logfile and installation
$logFileName = Join-Path $env:ProgramData "PH\$deployType-$productName.log" # Define path for logging

# Start logging
Start-Transcript -Path $logFileName

# Download and extract the icons zip file
$FileURL = ""
$DestinationPath = "C:\Windows\"
$DownloadPath = Join-Path -Path $DestinationPath -ChildPath "icons.zip"
$icoPaths = "C:\Windows\icons"
$urlPaths = "C:\Users\Public\Desktop\*.url"

if (Test-Path -Path $icoPaths) {
    Remove-Item -Path $icoPaths -Recurse -Force
    Remove-Item -Path $urlPaths -Recurse -Force     
    }

Invoke-WebRequest -Uri $FileURL -OutFile $DownloadPath
Expand-Archive -Path $DownloadPath -DestinationPath $DestinationPath -Force
Remove-Item -Path $DownloadPath

# Function to create URL shortcuts
function Create-UrlShortcut {
    param (
        [string]$urlShortcutPath,
        [string]$url,
        [string]$iconPath
    )
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($urlShortcutPath)
    $shortcut.TargetPath = $url
    $shortcut.Save()
    Add-Content -LiteralPath $urlShortcutPath -Value @(
        'IconIndex=0',
        "IconFile=$iconPath"
    )
}

# Function to create application shortcuts
function Create-AppShortcut {
    param (
        [string]$appShortcutPath,
        [string]$targetPath,
        [string]$iconPath
    )
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($appShortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.IconLocation = $iconPath
    $shortcut.Save()
}

# Create URL shortcuts
$urlShortcuts = @(
    @{Path="C:\Users\Public\Desktop\url1.url";  URL=""; 	Icon="C:\Windows\icons\ico1.ico"},
    @{Path="C:\Users\Public\Desktop\url2.url";  URL=""; 	Icon="C:\Windows\icons\ico2.ico"},
    @{Path="C:\Users\Public\Desktop\url3.url";  URL=""; 	Icon="C:\Windows\icons\ico3.ico"},
)

foreach ($shortcut in $urlShortcuts) {
    Create-UrlShortcut -urlShortcutPath $shortcut.Path -url $shortcut.URL -iconPath $shortcut.Icon
}

# Create application shortcuts
$appShortcuts = @(
    @{Path="C:\Users\Public\Desktop\Excel.lnk";	  Target="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"; 	Icon="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"},
    @{Path="C:\Users\Public\Desktop\Word.lnk";	  Target="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"; Icon="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"},
    @{Path="C:\Users\Public\Desktop\Outlook.lnk"; Target="C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"; Icon="C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"}
)

foreach ($shortcut in $appShortcuts) {
    Create-AppShortcut -appShortcutPath $shortcut.Path -targetPath $shortcut.Target -iconPath $shortcut.Icon
}

# Conclude logging
Stop-Transcript
