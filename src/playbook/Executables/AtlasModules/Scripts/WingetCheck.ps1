param (
    [switch]$NonInteractive,
    [switch]$NoDashes,
    [switch]$NonFatal
)

$dashes = '-' * 101
if (!$Silent -and !$NoDashes) {
    Write-Output $dashes
}

# Check internet by pinging Microsoft
if (!(Test-Connection -ComputerName "www.microsoft.com" -Count 1 -Quiet)) {
    if ($NonFatal) { return $false }
    
    Write-Error "You must have an internet connection to continue."
    if (!$NonInteractive) { Read-Pause }
    
    exit 2
}

Write-Output "Checking for WinGet..."

function WingetError($uri, $action) {
    Write-Host @"
You need the latest version of WinGet to use this script.
WinGet is included with 'App Installer' on the Microsoft Store.
"@ -ForegroundColor Yellow

    choice /c:yn /n /m "Would you like to open the Microsoft Store to $action it? [Y/N] "
    if ($LASTEXITCODE -eq 1) {
        Start-Process $uri
    }
    exit 3
}

# Check if WinGet is installed
if (!(Get-Command "winget" -EA 0)) {
    if ($NonFatal) { return $false }
    
    # Open Microsoft Store for App Installer if not installed
    WingetError "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1" "install"
}

# Check WinGet functionality by searching for VSCode
winget search "Microsoft Visual Studio Code" --accept-source-agreements --disable-interactivity --ignore-warnings *>$null
if (!$?) {
    if ($Silent) { exit 1 }

    # Open Microsoft Store to update apps if search fails
    WingetError "ms-windows-store://downloadsandupdates" "update"
}

if (!$NoDashes) {
    Write-Output "$dashes`n"
}

return $true