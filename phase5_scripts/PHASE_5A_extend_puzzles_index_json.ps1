Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
  $root = (Get-Location).Path
  if ($root -notlike "*MindLab_Starter_Project*") {
    throw "Run from project root: C:\Projects\MindLab_Starter_Project (current: $root)"
  }

  $target = Join-Path $root "backend\src\puzzles\index.json"
  if (-not (Test-Path $target)) { throw "Missing target puzzles file: $target" }

  # Phase 5 folders
  $scriptsDir = Join-Path $root "phase5_scripts"
  $logsDir    = Join-Path $root "phase5_logs"
  New-Item -ItemType Directory -Force $scriptsDir | Out-Null
  New-Item -ItemType Directory -Force $logsDir    | Out-Null

  # Backup
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $backup = Join-Path $logsDir ("index.json.bak_phase5a_{0}" -f $ts)
  Copy-Item -Force $target $backup

  # Load + validate JSON
  $raw = Get-Content $target -Raw
  $data = $raw | ConvertFrom-Json

  if ($null -eq $data) { throw "index.json parsed to null (unexpected)" }
  if (-not ($data -is [System.Array])) { throw "Expected index.json to be a JSON array (it is not)." }

  # Compute next numeric id (supports id as number or string)
  $ids = @()
  foreach ($p in $data) {
    if ($null -ne $p.id) {
      $n = 0
      if ([int]::TryParse([string]$p.id, [ref]$n)) { $ids += $n }
    }
  }
  $maxId = 0
  if ($ids.Count -gt 0) { $maxId = ($ids | Measure-Object -Maximum).Maximum }

  # Add NEW puzzles (edit count/questions only here)
  $new = @(
    @{ id = ($maxId + 1); question = "What is 5 + 7?"; options = @("10","12","13"); correctIndex = 1 },
    @{ id = ($maxId + 2); question = "Which is a mammal?"; options = @("Shark","Dolphin","Trout"); correctIndex = 1 },
    @{ id = ($maxId + 3); question = "What comes next: 2, 4, 6, __?"; options = @("7","8","9"); correctIndex = 1 }
  )

  # Append
  $before = $data.Count
  $data = @($data + $new)
  $after = $data.Count

  # Write back
  ($data | ConvertTo-Json -Depth 20) | Set-Content -Path $target -Encoding UTF8

  # Re-parse sanity
  Get-Content $target -Raw | ConvertFrom-Json | Out-Null

  Write-Host "PHASE_5A GREEN: puzzles extended" -ForegroundColor Green
  Write-Host ("Target : {0}" -f $target)
  Write-Host ("Backup : {0}" -f $backup)
  Write-Host ("Count  : {0} -> {1}" -f $before, $after)

  # Optional live check (won't fail the script if backend is down)
  try {
    $resp = Invoke-WebRequest "http://localhost:8085/puzzles" -UseBasicParsing
    Write-Host ("GET /puzzles : {0}" -f $resp.StatusCode)
  } catch {
    Write-Host ("NOTE: GET /puzzles skipped/failed: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
  }

} catch {
  Write-Host ("PHASE_5A ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
} finally {
  # Golden rule: return to project root
  try { Set-Location "C:\Projects\MindLab_Starter_Project" } catch {}
}
