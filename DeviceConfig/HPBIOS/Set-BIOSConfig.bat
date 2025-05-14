@echo off
REM This batch file will execute the BiosConfigUtility64.exe with /SetConfig commands
REM Fetch the current BIOS configuration and save it to a text file
C:\Temp\BiosConfigUtility64.exe /SetConfig:C:\Temp\Config.txt
pause