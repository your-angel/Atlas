$windir = [Environment]::GetFolderPath('Windows')
$removeEdge = "$windir\AtlasModules\Scripts\ScriptWrappers\RemoveEdge.ps1"
$edgePath = "$([Environment]::GetFolderPath('ProgramFilesx86'))\Microsoft\Edge\Application\msedge.exe"

function Invoke-EdgeTest {
    param (
        [switch]$OnlyEdge,
        [switch]$OnlyWebView,
        [switch]$NonInteractive
    )
            
    $dashes = "-" * 101
    Write-Output "`n$dashes"

    function Install {
        try {
            $edgeArgs = @{
                NonInteractive = $true
                InstallWebView = $true
            }
            if (!$edgeInstalled) { $edgeArgs.Add('InstallEdge', $true); Write-Output "" }

            & $removeEdge @edgeArgs
        } catch {
            Write-Host "`nSomething went wrong trying to update or install Edge: $_" -ForegroundColor Red
            if (!$NonInteractive) { Read-Pause }
            exit 1
        }
    }
    
    try {
        # Install only WebView if Edge is already installed, or if OnlyWebView set
        if ($OnlyWebView -or (Test-Path $edgePath)) {
            if ($OnlyEdge) {
                Write-Output "Edge is already installed, which is good as it's required for this script. :)"
                return
            }
            
            $edgeInstalled = $true
            Write-Output "Updating Edge WebView 2..."
            Install
            return
        } else {
            $edgeInstalled = $false
        }

        Write-Output "Microsoft Edge is required to use this script."
        choice /c:yn /n /m "Would you like to install Edge? [Y/N] "
        if ($LASTEXITCODE -eq 2) {
            Read-Pause -NewLine
            exit
        }
        Install
        return
    } finally {
        Write-Output "$dashes`n"
    }
}

Export-ModuleMember -Function Invoke-EdgeTest