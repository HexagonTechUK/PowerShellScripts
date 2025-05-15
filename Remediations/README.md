# Remediation Scripts for Endpoint Management

This repository contains a collection of PowerShell remediation scripts designed to detect and resolve common issues on Windows endpoints. These scripts are built for integration with Microsoft Intune, Configuration Manager, or other management tools in modern enterprise environments.

## 🛡️ Purpose

- Automate the detection and correction of configuration drift
- Enforce compliance with IT policies and security baselines
- Support proactive remediation of known issues
- Improve end-user experience with minimal disruption

## 🧰 Script Structure

Each remediation typically includes:
- `Detect.ps1`: Checks whether remediation is needed
- `Remediate.ps1`: Executes the fix if an issue is found
- `README.md`: Documentation on purpose and usage

## 📁 Repository Structure

```
/
├── Remediations/
│   ├── ExampleRemediation/
│   │   ├── Detect.ps1
│   │   ├── Remediate.ps1
│   │   └── README.md
├── utils/
│   └── shared-functions.ps1
└── README.md
```

## 🔍 Example Use Case

**Detect.ps1:**
```powershell
# Checks if BitLocker is enabled on C:
$bitlockerStatus = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty ProtectionStatus
if ($bitlockerStatus -ne 1) { exit 1 } else { exit 0 }
```

**Remediate.ps1:**
```powershell
# Enables BitLocker if not already enabled
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly
```

## 🚀 Deployment

These scripts are ready for deployment via:
- **Microsoft Intune proactive remediations**
- **Custom PowerShell scripts in Configuration Manager**
- **Manual or scheduled execution via task scheduler**

## 📌 Script Standards

All scripts follow a consistent header format:
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

Contributions are welcome! Please fork the repo and submit a pull request with new remediations or improvements.

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.
