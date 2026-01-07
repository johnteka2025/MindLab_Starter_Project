Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
  $root = (Get-Location).Path
  if ($root -notlike "*MindLab_Starter_Project*") {
    throw "Run from project root: C:\Projects\MindLab_Starter_Project (current: $root)"
  }

  $puzzlesPath  = Join-Path $root "backend\src\puzzles\index.json"
  $progressPath = Join-Path $root "backend\src\data\progress.json"
  $logsDir      = Join-Path $root "phase5_logs"
  New-Item -ItemType Directory -Force $logsDir | Out-Null

  if (-not (Test-Path $puzzlesPath))  { throw "Missing puzzles: $puzzlesPath" }
  if (-not (Test-Path $progressPath)) { throw "Missing progress: $progressPath" }

  $puzzles = (Get-Content $puzzlesPath -Raw | ConvertFrom-Json)
  if (-not ($puzzles -is [System.Array])) { throw "puzzles index.json must be a JSON array." }
  $newTotal = $puzzles.Count

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $backup = Join-Path $logsDir ("progress.json.bak_phase5b_{0}" -f $ts)
  Copy-Item -Force $progressPath $backup

  $prog = (Get-Content $progressPath -Raw | ConvertFrom-Json)
  $prog.total = $newTotal

  ($prog | ConvertTo-Json -Depth 20) | Set-Content -Path $progressPath -Encoding UTF8
  Get-Content $progressPath -Raw | ConvertFrom-Json | Out-Null

  Write-Host "PHASE_5B GREEN: progress total synced" -ForegroundColor Green
  Write-Host ("Total  : {0}" -f $newTotal)
  Write-Host ("Backup : {0}" -f $backup)

  try {
    $resp = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
    Write-Host ("GET /progress : {0} {1}" -f $resp.StatusCode, $resp.Content)
  } catch {
    Write-Host ("NOTE: GET /progress skipped/failed: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
  }

} catch {
  Write-Host ("PHASE_5B ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
} finally {
  try { Set-Location "C:\Projects\MindLab_Starter_Project" } catch {}
}
