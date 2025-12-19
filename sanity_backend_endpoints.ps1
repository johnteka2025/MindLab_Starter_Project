# sanity_backend_endpoints.ps1
$base = "http://localhost:8085"

Write-Host "Checking backend health..." -ForegroundColor Cyan
try {
  $h = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri "$base/health"
  Write-Host "GET /health HTTP: $($h.StatusCode)" -ForegroundColor Green
} catch {
  Write-Host "BACKEND NOT RUNNING on 8085. Start it first (npm start). Error: $($_.Exception.Message)" -ForegroundColor Red
  throw
}

Write-Host "`nChecking key endpoints..." -ForegroundColor Cyan
$paths = @("/__server_id", "/puzzles", "/progress")
foreach ($p in $paths) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri ($base + $p)
    Write-Host "GET $p HTTP: $($r.StatusCode)" -ForegroundColor Green
    if ($p -in @("/__server_id","/progress")) {
      try { ($r.Content | ConvertFrom-Json) | ConvertTo-Json -Depth 20 } catch {}
    }
    if ($p -eq "/puzzles") {
      try {
        $j = $r.Content | ConvertFrom-Json
        if ($j -is [System.Array]) {
          Write-Host "Puzzles count: $($j.Count)" -ForegroundColor Green
          ($j | Select-Object -First 2) | ConvertTo-Json -Depth 20
        } else {
          Write-Host "/puzzles did not return an array. Printing JSON:" -ForegroundColor Yellow
          ($j | ConvertTo-Json -Depth 20)
        }
      } catch {
        Write-Host "/puzzles returned non-JSON or parse failed. Raw:" -ForegroundColor Yellow
        $r.Content
      }
    }
  } catch {
    Write-Host "FAILED GET $p : $($_.Exception.Message)" -ForegroundColor Red
  }
}

Write-Host "`nDONE." -ForegroundColor Cyan
