#Requires -RunAsAdministrator

param (
    [switch]$NonInteractive
)

$windir = [Environment]::GetFolderPath('Windows')
& "$windir\AtlasModules\initPowerShell.ps1"

# Check if Edge is installed
$edgeArgs = @{
    OnlyEdge = $true
    NonInteractive = $NonInteractive
}
Invoke-EdgeTest @edgeArgs

# Decide if Copilot is available
# If not, it could be 24H2 (which replaces it with an app)
try {
    $copilotAvailable = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Copilot" -Name "IsCopilotAvailable" -EA 0
} catch {
    $appText = "You can find the Copilot app in your Start Menu."
}

if ($copilotAvailable -eq 0) {
    Write-Warning "Copilot on the taskbar isn't available, the app will be installed instead."
    & "$winver\AtlasModules\Scripts\wingetCheck.cmd" /nodashes $(if ($NonInteractive) { '/silent' })
    if ($LASTEXITCODE -ne 0) { exit 1 }

    Write-Output "Installing Copilot..."
    winget install -e --id 9NHT9RB2F4HD --uninstall-previous -h --accept-source-agreements --accept-package-agreements --force --disable-interactivity | Out-Null
} else {
    # Show in taskbar
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 1 -EA 0
}

# Delete policy
Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Force -EA 0

# Restart Explorer to apply changes
Restart-Explorer

Write-Host "Finished, changes are applied. $appText" -ForegroundColor Green
Read-Pause