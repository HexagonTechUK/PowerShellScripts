﻿# Created by sistena.co.uk
# Author Damien Cresswell

# Function to check Windows image health with DISM
function Check-DISM {
    Write-Host "Checking Windows image health with DISM..."
    $dismOutput = & dism /Online /Cleanup-Image /ScanHealth 2>&1
    if ($dismOutput -match "No component store corruption detected" -or $dismOutput -match "The operation completed successfully") {
        Write-Host "No issues detected by DISM"
        return $false
    } else {
        Write-Host "DISM detected issues that require repair."
        return $true
    }
}

function Check-SFC {
    Write-Host "Checking system file integrity with SFC..."
    $sfcOutput = & sfc /verifyonly 2>&1
    Write-Host $sfcOutput  # Optionally display the output for manual inspection
    if ($sfcOutput -match "Windows Resource Protection did not find any integrity violations.") {
        Write-Host "No issues detected by SFC."
        return $false
    } elseif ($sfcOutput -match "Windows Resource Protection found corrupt files") {
        Write-Host "SFC reported corrupt files. Checking CBS.log for details..."
        # Analyzing CBS.log to determine if the reported issues are critical
        $cbsLogContent = Get-Content C:\Windows\Logs\CBS\CBS.log
        if ($cbsLogContent -match "some specific error pattern you're interested in") {
            Write-Host "Critical issues found in CBS.log."
            return $true
        } else {
            Write-Host "No critical issues found in CBS.log."
            return $false
        }
    } else {
        Write-Host "SFC output is inconclusive or indicates minor issues."
        return $false
    }
}

# Execute checks
$dismCheck = Check-DISM
$sfcCheck = Check-SFC

# Determine if exit code 1 is needed
if ($dismCheck -or $sfcCheck) {
    Write-Host "Repairs are required. Exiting with code 1."
    exit 1
} else {
    Write-Host "No repairs are needed."
    exit 0
}