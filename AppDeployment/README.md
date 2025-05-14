# WinGet Scripts for Application Deployment and Management

This repository contains a collection of PowerShell scripts leveraging the [Windows Package Manager (WinGet)](https://learn.microsoft.com/en-us/windows/package-manager/winget/) to automate application installation, updates, and removal across managed Windows devices.

## 📦 Features

- Automated installation of common and approved applications
- Support for silent installs with customization options
- Scripted application updates via WinGet upgrade
- App removal for decommissioning or policy enforcement
- Logging and error handling included
- Designed for use in enterprise environments

## 📁 Repository Structure

```
/
├─── AppName/
│   └── Get-AppVersion.ps1
│   └── Install-App.ps1
│   └── Remove-App.ps1
|   └── README.md
```

## 🚀 Getting Started

### Prerequisites

- Windows 10 1809+ or Windows 11
- WinGet (v1.4 or later) installed and configured
- PowerShell 5.1 or PowerShell Core 7+

### Example Usage

**Install Applications:**

```powershell
.\Install-7Zip.ps1
```

**Detect Applications:**

```powershell
.\Get-7ZipVersion.ps1
```

**Remove Applications:**

```powershell
.\Remove-7Zip.ps1
```

## ⚙️ Configuration

- All scripts support logging and can be integrated into broader deployment pipelines or Intune/Endpoint Manager.

## 📌 Script Standards

Each script adheres to a standard PowerShell header format, including:

```powershell
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER
.OUTPUTS
.NOTES
.EXAMPLE
#>
```

## 🛠️ Contributing

Contributions and suggestions are welcome. Please fork the repo and submit a pull request with your changes.

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.
