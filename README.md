# PowerShell Scripts for Modern Endpoint Management

This repository contains PowerShell scripts designed for use with Microsoft Intune to support modern device management, configuration, and automation in enterprise environments.

## 🎯 Purpose

These scripts help automate and streamline:
- Device configuration
- Application deployment
- Security and compliance enforcement
- Custom policy implementation
- User environment setup

## 📁 Repository Structure

```
/
├── DeviceConfig/
│   └── Set-Timezone.ps1
├── AppDeployment/
│   └── Install-CustomApp.ps1
├── UserConfig/
│   └── Configure-StartMenu.ps1
├── Remediations/
│   ├── Detect.ps1
│   └── Remediate.ps1
└── README.md
```

## 🚀 Deployment via Intune

These scripts are intended for use in:
- **Device/Script Deployment**: Intune > Devices > Scripts
- **Proactive Remediations**: Intune > Reports > Endpoint Analytics > Proactive Remediations
- **Win32 App Packaging**: Packaged using the [Microsoft Win32 Content Prep Tool](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management)

## 🧪 Example Scenarios

**DeviceConfig/Set-Timezone.ps1**
```powershell
tzutil /s "GMT Standard Time"
```

**AppDeployment/Install-CustomApp.ps1**
```powershell
Start-Process -FilePath ".\setup.exe" -ArgumentList "/quiet /norestart" -Wait
```

**UserConfig/Configure-StartMenu.ps1**
```powershell
Copy-Item -Path ".\StartLayout.xml" -Destination "$env:APPDATA\Microsoft\Windows\Start Menu"
```

## 📌 Script Standards

All scripts include standardized headers for clarity and documentation:

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

Contributions and improvements are welcome. Please fork the repository and submit a pull request with your changes.

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.
