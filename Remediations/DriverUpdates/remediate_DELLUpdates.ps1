<#
.SYNOPSIS
    Detection script for Dell Command Update

.DESCRIPTION
   This script uses Dell Command Update to retrieve and firmware and drivers updates

.PARAMETER 
    dcu-cli.exe -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=firmware,driver -outputlog=C:\Temp\Dell_report\update.log -autoSuspendBitLocker=enable

.OUTPUTS
    PS> .\remediateDriverUpdates.ps1
    2025-05-23 19:31 | Compliant, no drivers needed

.NOTES
    File Name : remediateDriverUpdates.ps1  
    Author    : Florian Salzmann, modified for DB Cargo
    Created   : {YYYY-MM-DD}  
    Version   : 1.0 - Initial Script  
    Requires  : {Write any requirements or prerequisites for this script}  

#>

# Variables (complete these):
$deployType   = "remediate"    #--------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName  = "DriverUpdates"   #-----------------------------------------------# Application name or function for logfile   
$logFileName  = Join-Path $env:ProgramData "DB\$deployType-$productName.log"  #---# Path to script logfile
$DCU_folder   = "C:\Program Files\Dell\CommandUpdate"    #------------------------# Path for Dell Command Update
$DCU_report   = "C:\Temp\Dell_report\update.log"   #------------------------------# Path for Dell Command Update reports
$DCU_exe      = "$DCU_folder\dcu-cli.exe"    #------------------------------------# Path for Dell Command Update executable
$DCU_category = "firmware,driver"    #--------------------------------------------# bios,firmware,driver,application,others  

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

try{
    Start-Process $DCU_exe -ArgumentList "/applyUpdates -silent -reboot=disable -updateType=$DCU_category -outputlog=$DCU_report -autoSuspendBitLocker=enable -encryptedPassword=$DCU_encryptedPassword -encryptionKey=$DCU_encryptionKey" -Wait
    Write-Log "Installation completed"
}catch{
    Write-Log $_.Exception
}

# Usermanual: https://www.dell.com/support/manuals/de-ch/command-update/dellcommandupdate_rg/dell-command-%7C-update-cli-commands?guid=guid-92619086-5f7c-4a05-bce2-0d560c15e8ed&lang=en-us

# End of script