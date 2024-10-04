function Get-ExplorerStatus {
    if (Get-Process -Name explorer -EA 0) {
        $true
    } else {
        $false
    }
}

function Restart-Explorer {
    param (
        [switch]$ExplorerStarted = !(Get-ExplorerStatus)
    )
    if ($ExplorerStarted) { return }
    Stop-Process -Name explorer -Force -EA 0
}


function Start-Explorer {
    Start-Process explorer
}

function Stop-Explorer {
    # If Explorer isn't started, return false
    if (!(Get-ExplorerStatus)) { return $false }

    taskkill /f /im explorer.exe *>$null
    return $true
}

Export-ModuleMember -Function Get-ExplorerStatus, Restart-Explorer, Start-Explorer, Stop-Explorer