param(
    [string]$Base = "http://localhost:5177"
)

Write-Host "=== MindLab frontend debug ===" -ForegroundColor Cyan
Write-Host "Base URL: $Base" -ForegroundColor Cyan
Write-Host ""

function Show-Check {
    param(
        [string]$Path
    )
    $url = "$Base$Path"
    Write-Host "---- Checking $url ----" -ForegroundColor Yellow
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing
        Write-Host "Status code : $($resp.StatusCode)" -ForegroundColor Green
        Write-Host "Content len : $($resp.Content.Length)" -ForegroundColor Green
        Write-Host ""
        $lines = $resp.Content -split "`n"
        $preview = $lines | Select-Object -First 15
        Write-Host "First 15 lines of response:" -ForegroundColor DarkCyan
        $preview
        Write-Host ""
    }
    catch {
        Write-Host "ERROR calling $url : $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# 2) Check the HTML pages
Show-Check "/app"
Show-Check "/app/daily"

# 3) Check the JS entry points we *expect* to exist
#    (a) Vite-style dev entry
Show-Check "/src/main.tsx"

#    (b) Built assets bundle (prod) – this will usually 404 in dev,
#        but we show it anyway in case server is serving /dist
Show-Check "/assets/main.js"
Show-Check "/dist/index.html"

Write-Host "=== Debug script finished ===" -ForegroundColor Cyan
