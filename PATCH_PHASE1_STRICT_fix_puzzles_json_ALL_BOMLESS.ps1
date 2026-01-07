# PATCH_PHASE1_STRICT_fix_puzzles_json_ALL_BOMLESS.ps1
# Purpose: Fix /puzzles 500 caused by UTF-8 BOM and/or wrong puzzle file being read.
# Golden Rules:
# - Always use absolute paths
# - Always back up before modifying
# - Always sanity check (Node JSON.parse + HTTP call)
# - Always return to project root

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $enc = New-Object System.Text.UTF8Encoding($false) # false => NO BOM
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Backup-IfExists([string]$Path, [string]$BackupDir) {
  if (!(Test-Path $BackupDir)) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null }
  if (Test-Path $Path) {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $name = Split-Path $Path -Leaf
    $dest = Join-Path $BackupDir "$name.bak_$stamp"
    Copy-Item -Force $Path $dest
    Write-Host "Backed up: $Path -> $dest"
  } else {
    Write-Host "Will create: $Path"
  }
}

function Node-Parse-Check([string]$Path) {
  $node = Get-Command node -ErrorAction SilentlyContinue
  if (-not $node) {
    Write-Host "WARN: node not found in PATH. Skipping Node JSON.parse check for $Path" -ForegroundColor Yellow
    return
  }

  $js = @"
const fs = require('fs');
const p = process.argv[1];
const s = fs.readFileSync(p,'utf8');
try {
  const v = JSON.parse(s);
  const isArr = Array.isArray(v);
  const len = isArr ? v.length : (v && v.puzzles && Array.isArray(v.puzzles) ? v.puzzles.length : 0);
  console.log('OK JSON.parse:', p, 'array=', isArr, 'len=', len);
} catch (e) {
  console.error('FAIL JSON.parse:', p);
  console.error(String(e && e.message ? e.message : e));
  process.exit(2);
}
"@

  $tmp = Join-Path $env:TEMP ("mindlab_jsoncheck_" + [Guid]::NewGuid().ToString("N") + ".js")
  Write-Utf8NoBom -Path $tmp -Content $js

  & node $tmp $Path
  Remove-Item -Force $tmp -ErrorAction SilentlyContinue
}

Write-Host "============================================================"
Write-Host "Phase 1 STRICT puzzle JSON fix (BOMLESS) starting"
Write-Host "============================================================"

$root = "C:\Projects\MindLab_Starter_Project"
Set-Location $root
Write-Host "Root: $(Get-Location)"

$backupDir = Join-Path $root "backend\backups"

# Candidate puzzle JSON files the backend may read
$targets = @(
  "C:\Projects\MindLab_Starter_Project\backend\src\puzzles.json",
  "C:\Projects\MindLab_Starter_Project\backend\src\puzzles\puzzles.json",
  "C:\Projects\MindLab_Starter_Project\backend\src\puzzles\index.json"
)

# Canonical JSON ARRAY (must be an array for the UI + correctnessIndex support)
# IMPORTANT: keep it strict JSON, no trailing commas.
$canonical = @"
[
  {
    "id": 1,
    "question": "What is 2 + 2?",
    "options": ["3", "4", "5"],
    "correctIndex": 1
  },
  {
    "id": 2,
    "question": "What is the color of the sky?",
    "options": ["Blue", "Green", "Red"],
    "correctIndex": 0
  },
  {
    "id": 3,
    "question": "Which shape has 3 sides?",
    "options": ["Triangle", "Square", "Circle"],
    "correctIndex": 0
  }
]
"@

Write-Host "`n--- Backing up + writing targets (UTF8 NO BOM) ---"
foreach ($t in $targets) {
  # ensure folder exists
  $dir = Split-Path $t -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

  Backup-IfExists -Path $t -BackupDir $backupDir

  Write-Utf8NoBom -Path $t -Content $canonical
  Write-Host "WROTE (BOMLESS): $t"
}

Write-Host "`n--- Sanity: Node JSON.parse each target ---"
foreach ($t in $targets) {
  if (Test-Path $t) { Node-Parse-Check -Path $t }
}

Write-Host "`n--- Runtime sanity: call backend endpoints (raw) ---"
$urls = @(
  "http://127.0.0.1:8085/health",
  "http://127.0.0.1:8085/puzzles",
  "http://127.0.0.1:8085/progress"
)

foreach ($u in $urls) {
  Write-Host "`n==== GET $u ===="
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $u
    Write-Host "STATUS: $($resp.StatusCode)"
    Write-Host "BODY (first 400 chars):"
    $body = [string]$resp.Content
    if ($body.Length -gt 400) { $body.Substring(0,400) } else { $body }
  } catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
      try {
        $code = [int]$_.Exception.Response.StatusCode
        Write-Host "STATUS: $code" -ForegroundColor Red
      } catch {}
    }
    throw
  }
}

# Return to project folder (Golden Rule)
Set-Location $root
Write-Host "`n== Phase 1 STRICT puzzle JSON fix complete. Returned to: $(Get-Location) =="
