# PATCH_PHASE1_FORCE_GOOD_backend_src_puzzles_json.ps1
# Force backend\src\puzzles.json to be valid JSON (array). No parsing/repair attempts.
# Golden rules: backups, strict output, sanity checks, return to root.

$ErrorActionPreference = "Stop"

function Write-Section($t) {
  Write-Host ""
  Write-Host ("=" * 78)
  Write-Host $t
  Write-Host ("=" * 78)
}

function Backup-File($path, $backupDir) {
  if (-not (Test-Path $path)) { return $null }
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = Join-Path $backupDir ("{0}.bak_{1}" -f (Split-Path $path -Leaf), $stamp)
  Copy-Item -Force $path $bak
  return $bak
}

function Invoke-RawGet($url) {
  $resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $url
  return [pscustomobject]@{ StatusCode = $resp.StatusCode; Content = $resp.Content }
}

Write-Section "Phase 1 FORCE GOOD puzzles.json starting"

$root = "C:\Projects\MindLab_Starter_Project"
if (-not (Test-Path $root)) { throw "Missing project root: $root" }
Set-Location $root
Write-Host "Root: $root"

$backupDir = Join-Path $root "backend\backups"
$target    = Join-Path $root "backend\src\puzzles.json"

$bak = Backup-File $target $backupDir
if ($bak) { Write-Host "Backed up target to: $bak" } else { Write-Host "Target did not exist; will create it." }

# Hard-coded valid JSON array. (Includes correctIndex required by Phase 1.)
$json = @'
[
  { "id": 1, "question": "What is 2 + 2?", "options": ["3","4","5"], "correctIndex": 1 },
  { "id": 2, "question": "What is the color of the sky?", "options": ["Blue","Green","Red"], "correctIndex": 0 },
  { "id": 3, "question": "Which shape has 3 sides?", "options": ["Triangle","Square","Circle"], "correctIndex": 0 }
]
'@

# Strict parse check before writing
Write-Host "Validating JSON parses..."
$null = ($json | ConvertFrom-Json)
Write-Host "OK: JSON parses."

# Write file (UTF8)
Set-Content -Path $target -Value $json -Encoding UTF8
Write-Host "WROTE: $target"

# Validate disk content parses
Write-Host "Validating disk JSON parses..."
$raw = Get-Content $target -Raw -Encoding UTF8
$null = ($raw | ConvertFrom-Json)
Write-Host "OK: Disk JSON parses."

Write-Section "Runtime sanity (raw): backend endpoints"
$urls = @(
  "http://127.0.0.1:8085/health",
  "http://127.0.0.1:8085/puzzles",
  "http://127.0.0.1:8085/progress"
)

foreach ($u in $urls) {
  Write-Host ""
  Write-Host "==== GET $u ===="
  $r = Invoke-RawGet $u
  Write-Host "STATUS: $($r.StatusCode)"
  Write-Host "BODY:"
  $r.Content
}

Set-Location $root
Write-Host ""
Write-Host "== Phase 1 FORCE GOOD complete. Returned to: $(Get-Location) =="
