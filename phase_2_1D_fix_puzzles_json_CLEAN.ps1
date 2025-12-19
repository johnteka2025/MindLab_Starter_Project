#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Gray }
function Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[ERROR] $m" -ForegroundColor Red; throw $m }

$startDir = Get-Location

try {
  Say "=== Phase 2.1D (CLEAN): Fix puzzles.json + run backend tests ==="

  $projectRoot = "C:\Projects\MindLab_Starter_Project"
  if (-not (Test-Path $projectRoot)) { Fail "Project root not found: $projectRoot" }

  $backendDir = Join-Path $projectRoot "backend"
  if (-not (Test-Path $backendDir)) { Fail "Backend folder not found: $backendDir" }

  $puzzlesPath = Join-Path $backendDir "src\puzzles.json"
  if (-not (Test-Path $puzzlesPath)) { Fail "Missing puzzles file: $puzzlesPath" }

  Info "ProjectRoot: $projectRoot"
  Info "BackendDir : $backendDir"
  Info "Puzzles    : $puzzlesPath"

  # 1) Backup (reversible)
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $backupDir = Join-Path $backendDir "backups\manual_edits\PHASE_2_1D_CLEAN_$stamp"
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  $backupFile = Join-Path $backupDir "puzzles.json.BEFORE"
  Copy-Item -Force $puzzlesPath $backupFile
  Ok "Backup created: $backupFile"

  # 2) Write VALID JSON array (no BOM)
  $fixedObj = @(
    @{
      id = 1
      question = "What is 2 + 2?"
      options = @("3","4","5")
    },
    @{
      id = 2
      question = "What is the color of the sky?"
      options = @("Blue","Green","Red")
    },
    @{
      id = 3
      question = "Which shape has 3 sides?"
      options = @("Triangle","Square","Circle")
    }
  )

  $json = $fixedObj | ConvertTo-Json -Depth 10
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($puzzlesPath, $json, $utf8NoBom)
  Ok "Wrote valid JSON to: $puzzlesPath"

  # 3) Proof: Node JSON.parse must succeed
  Say "=== Proof: Node JSON.parse must succeed ==="
  $nodeCmd = 'const fs=require("fs"); const p=process.argv[1]; const s=fs.readFileSync(p,"utf8"); JSON.parse(s); console.log("OK: puzzles.json parses as JSON");'
  & node -e $nodeCmd $puzzlesPath
  Ok "Node parse proof passed."

  # 4) Run backend tests safely (avoids npm.ps1 StrictMode issues)
  Say "=== Running backend tests (npm test) ==="
  Push-Location $backendDir
  try {
    Set-StrictMode -Off
    & npm test
    $exit = $LASTEXITCODE
    Set-StrictMode -Version Latest
    if ($exit -ne 0) { Fail "npm test failed with exit code $exit" }
    Ok "npm test finished green."
  }
  finally {
    Pop-Location
  }

  Ok "Phase 2.1D CLEAN complete."
  Info "Backups in: $backupDir"
}
finally {
  Set-Location $startDir
  Info "Returned to: $((Get-Location).Path)"
  Read-Host "Press ENTER to continue"
}