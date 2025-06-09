<#
.SYNOPSIS
    Detection script for Dell Command Update

.DESCRIPTION
   This script uses Dell Command Update to retrieve and firmware and drivers updates.

.PARAMETER 
    dcu-cli.exe -ArgumentList "/scan -updateType=firmware,driver -report=C:\Temp\Dell_report"

.OUTPUTS
    PS>.\detectDriverUpdates.ps1
    2025-05-23 19:31 | Compliant, no drivers needed

.NOTES
    File Name : detectDriverUpdates.ps1  
    Author    : Florian Salzmann, modified for DB Cargo
    Created   : 2025-05-23  
    Version   : 1.0 - Initial Script  
    Requires  : Requires Dell Command Update to be installed  

#>

# Variables (complete these):
$deployType   = "detect"    #-----------------------------------------------------# Deployment type: Install, Upgrade, Removal   
$productName  = "DriverUpdates"   #-----------------------------------------------# Application name or function for logfile   
$logFileName  = Join-Path $env:ProgramData "DB\$deployType-$productName.log"  #---# Path to script logfile
$DCU_folder   = "C:\Program Files\Dell\CommandUpdate"    #------------------------# Path for Dell Command Update
$DCU_report   = "C:\Temp\Dell_report"   #-----------------------------------------# Path for Dell Command Update reports
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

Try {
    if([System.IO.File]::Exists($DCU_exe)){
        if(Test-Path "$DCU_report\DCUApplicableUpdates.xml"){Remove-Item "$DCU_report\DCUApplicableUpdates.xml" -Recurse -Force}
	Start-Process $DCU_exe -ArgumentList "/scan -updateType=$DCU_category -report=$DCU_report" -Wait
        
	$DCU_analyze = if(Test-Path "$DCU_report\DCUApplicableUpdates.xml"){[xml](get-content "$DCU_report\DCUApplicableUpdates.xml")}
        
        if($DCU_analyze.updates.update.SelectNodes.Count -lt 1){
            Write-Log "Compliant, no drivers needed"
            Exit 0
        }else{
            Write-Log "Found drivers to download/install: $($DCU_analyze.updates.update.name)"
            Exit 1
        }
        
        
    }else{
        Write-Log "DELL Command Update missing"
        Exit 1
    }
} 
Catch {
    Write-Log $_.Exception
    Exit 1
}

# End of script
