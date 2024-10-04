#Requires -RunAsAdministrator

param (
    [switch]$NonInteractive
)

$windir = [Environment]::GetFolderPath('Windows')
& "$windir\AtlasModules\initPowerShell.ps1"

# Remove PWA/app version
Get-AppxPackage -AllUsers Microsoft.Copilot* | Remove-AppxPackage -AllUsers

# Kill Explorer to ensure Registry changes apply
$exp = Stop-Explorer

# Registry changes
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -Force -EA 0
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -PropertyType DWord -Value 1 -Force

# Start Explorer again
Restart-Explorer -ExplorerStarted $exp

Write-Host "Finished, changes are applied." -ForegroundColor Green
Read-Pause