function Complete-Step {
    param(
        [int]$Code = 0,
        [string]$Message = ""
    )

    if ($Message) {
        if ($Code -eq 0) {
            Write-Host $Message -ForegroundColor Green
        }
        elseif ($Code -eq 2) {
            Write-Host $Message -ForegroundColor Yellow
        }
        else {
            Write-Host $Message -ForegroundColor Red
        }
    }

    $global:LASTEXITCODE = $Code
    return
}

function Wait-ForUser {
    if ($Host.Name -match "ConsoleHost|Visual Studio Code Host") {
        Write-Host ""
        Write-Host "STEP COMPLETE. Review output above. Run next command when ready." -ForegroundColor Cyan
        Write-Host ""
    }
}
