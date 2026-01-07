# PATCH_16B_fix_persistence_nodemon_loop.ps1
# Fix nodemon restart loop caused by writing progress.json under backend/src (watched tree)
# Golden rules: absolute paths, backups, sanity checks, return to project root

$ErrorActionPreference = "Stop"

$ROOT    = "C:\Projects\MindLab_Starter_Project"
$BACKEND = Join-Path $ROOT "backend"
$SRC     = Join-Path $BACKEND "src"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: ${p}" }
}

function Backup-File([string]$filePath, [string]$tag) {
  if (Test-Path $filePath) {
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $bak = "$filePath.bak_$tag`_$ts"
    Copy-Item $filePath $bak -Force
    Write-Host "Backup created: $bak" -ForegroundColor Green
  }
}

try {
  Set-Location $ROOT

  Assert-Path $BACKEND "backend folder"
  Assert-Path $SRC "backend\src folder"

  $progressPersistence = Join-Path $SRC "progressPersistence.cjs"
  $serverEntry         = Join-Path $SRC "server.cjs"

  Assert-Path $progressPersistence "backend\src\progressPersistence.cjs"
  Assert-Path $serverEntry "backend\src\server.cjs"

  # 1) Create nodemon.json to ignore persisted data
  $nodemonJsonPath = Join-Path $BACKEND "nodemon.json"
  Backup-File $nodemonJsonPath "before_ignore"

  $nodemonObj = @'
{
  "watch": ["src"],
  "ignore": [
    "data/progress.json",
    "src/data/progress.json"
  ]
}
'@
  Set-Content -Path $nodemonJsonPath -Value $nodemonObj -Encoding UTF8
  Write-Host "Created/Updated nodemon ignore file: $nodemonJsonPath" -ForegroundColor Green

  # 2) Move progress.json OUT of src tree (to backend\data\progress.json)
  $oldDataDir = Join-Path $SRC "data"
  $oldProgress = Join-Path $oldDataDir "progress.json"

  $newDataDir = Join-Path $BACKEND "data"
  $newProgress = Join-Path $newDataDir "progress.json"

  if (-not (Test-Path $newDataDir)) {
    New-Item -ItemType Directory -Path $newDataDir | Out-Null
    Write-Host "Created data dir: $newDataDir" -ForegroundColor Green
  }

  if (Test-Path $oldProgress) {
    Backup-File $oldProgress "before_move"
    Move-Item -Path $oldProgress -Destination $newProgress -Force
    Write-Host "Moved progress file to: $newProgress" -ForegroundColor Green
  } else {
    if (-not (Test-Path $newProgress)) {
      $defaultJson = @'
{
  "total": 0,
  "solved": 0,
  "solvedToday": 0,
  "totalSolved": 0,
  "streak": 0,
  "solvedIds": [],
  "solvedPuzzleIds": {}
}
'@
      Set-Content -Path $newProgress -Value $defaultJson -Encoding UTF8
      Write-Host "Created new progress file: $newProgress" -ForegroundColor Green
    } else {
      Write-Host "Progress file already exists: $newProgress" -ForegroundColor Yellow
    }
  }

  # 3) Update progressPersistence.cjs to write/read from backend\data\progress.json (NOT src\data)
  Backup-File $progressPersistence "before_path_fix"

  $pp = Get-Content -Path $progressPersistence -Raw

  $injection = @'
const path = require("path");
const fs = require("fs");

// Persist file lives OUTSIDE src so nodemon won't restart on writes
const DATA_FILE = path.join(__dirname, "..", "data", "progress.json");

function ensureFile() {
  try {
    const dir = path.dirname(DATA_FILE);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    if (!fs.existsSync(DATA_FILE)) {
      fs.writeFileSync(
        DATA_FILE,
        JSON.stringify({
          total: 0,
          solved: 0,
          solvedToday: 0,
          totalSolved: 0,
          streak: 0,
          solvedIds: [],
          solvedPuzzleIds: {}
        }, null, 2),
        "utf8"
      );
    }
  } catch (e) {
    console.warn("[progressPersistence] ensureFile failed:", String(e));
  }
}
'@

  if ($pp -match "DATA_FILE") {
    $pp = [regex]::Replace($pp, "const\s+DATA_FILE\s*=\s*.*?;", 'const DATA_FILE = path.join(__dirname, "..", "data", "progress.json");')
    if ($pp -notmatch 'require\("path"\)' -or $pp -notmatch 'require\("fs"\)') {
      # Ensure required modules exist (prepend minimal requires if missing)
      $pp = $injection + "`r`n`r`n" + $pp
    }
  } else {
    if ($pp -match "('use strict';\s*)") {
      $pp = [regex]::Replace($pp, "('use strict';\s*)", "`$1`r`n$injection`r`n")
    } else {
      $pp = "$injection`r`n`r`n$pp"
    }
  }

  if ($pp -notmatch "ensureFile\(\);") {
    $pp = "$pp`r`n`r`n// Ensure persistence file exists once at startup`r`nensureFile();`r`n"
  }

  Set-Content -Path $progressPersistence -Value $pp -Encoding UTF8
  Write-Host "Updated persistence path in: $progressPersistence" -ForegroundColor Green

  # 4) Sanity checks (API must be up).
  Write-Host "`n=== SANITY: Backend endpoints (must be 200) ===" -ForegroundColor Cyan

  $health = Invoke-WebRequest "http://localhost:8085/health" -UseBasicParsing
  Write-Host "Health: $($health.StatusCode)" -ForegroundColor Green

  $reset = Invoke-WebRequest "http://localhost:8085/progress/reset" -Method Post -UseBasicParsing
  Write-Host "Progress reset: $($reset.StatusCode)" -ForegroundColor Green

  $solve = Invoke-WebRequest "http://localhost:8085/progress/solve" -Method Post -ContentType "application/json" -Body '{ "puzzleId":"demo-1" }' -UseBasicParsing
  Write-Host "Progress solve: $($solve.StatusCode)" -ForegroundColor Green

  $get = Invoke-WebRequest "http://localhost:8085/progress" -UseBasicParsing
  Write-Host "Progress get: $($get.StatusCode)" -ForegroundColor Green

  Write-Host "`nPATCH_16B GREEN: nodemon loop prevented (data moved + ignored)." -ForegroundColor Green
}
finally {
  Set-Location $ROOT
  Write-Host "Returned to project root: $ROOT" -ForegroundColor Green
}
