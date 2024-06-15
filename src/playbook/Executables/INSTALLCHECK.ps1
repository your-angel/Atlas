if ((Get-ItemProperty $oemInfo -Name "Model" -EA 0).Model -notlike "*Atlas*") {
    Write-Output "Model doesn't contain Atlas, Atlas doesn't seem to be installed currently."
    if (20 -lt ((Get-Date) - (Get-CimInstance Win32_OperatingSystem).InstallDate).Days) {
        @"
Windows seems to have been installed a while ago. A full Windows reinstall is highly recommended to ensure your initial install of Atlas works without problems.

Atlas will install anyways, but remember this if there's issues.

Follow our installation guide: https://docs.atlasos.net/getting-started/installation/
"@ | msg *
    }
    exit 2
}