# PATCH_PHASE1_POLICYA_quarantine_puzzlesjson_FULL.ps1
# Policy A: backend loads ONLY backend/src/puzzles/index.json
# Option 1: quarantine puzzles.json into backend/src/puzzles/_legacy/puzzles.json
# Golden Rules: backups, sanity checks, return to root

$ErrorActionPreference = "Stop"

$ROOT = "C:\Projects\MindLab_Starter_Project"
if (-not (Test-Path $ROOT)) { throw "ROOT not found: $ROOT" }

Set-Location $ROOT
Write-Host "Root: $(Get-Location)"

# ---- Paths ----
$backendDir = Join-Path $ROOT "backend"
$backendSrc = Join-Path $backendDir "src"
$puzzlesDir = Join-Path $backendSrc "puzzles"

$serverPath = Join-Path $backendSrc "server.cjs"
$indexPath  = Join-Path $puzzlesDir "index.json"
$puzzlesPath = Join-Path $puzzlesDir "puzzles.json"

$legacyDir = Join-Path $puzzlesDir "_legacy"
$legacyPuzzlesPath = Join-Path $legacyDir "puzzles.json"
$legacyReadmePath  = Join-Path $legacyDir "README.md"

$backendTestsDir = Join-Path $backendDir "tests"
$policyTestPath = Join-Path $backendTestsDir "policy_puzzles_source.test.js"

# ---- Preflight ----
Write-Host "`n=== Preflight checks ==="
foreach ($p in @($backendDir, $backendSrc, $puzzlesDir)) {
  if (-not (Test-Path $p)) { throw "Missing folder: $p" }
}
if (-not (Test-Path $serverPath)) { throw "Missing server file: $serverPath" }
if (-not (Test-Path $indexPath))  { throw "Missing index.json (required by Policy A): $indexPath" }

# ---- Backup helper ----
function Backup-File([string]$path, [string]$backupDir) {
  if (-not (Test-Path $path)) { return $null }
  if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Force -Path $backupDir | Out-Null }
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $name = Split-Path $path -Leaf
  $dest = Join-Path $backupDir "$name.bak_$stamp"
  Copy-Item -Force $path $dest
  return $dest
}

# ---- 1) Ensure server loads ONLY index.json ----
Write-Host "`n=== 1) Enforce Policy A in backend/src/server.cjs ==="
$backendBackupDir = Join-Path $backendDir "backups"
$serverBak = Backup-File $serverPath $backendBackupDir
if ($serverBak) { Write-Host "Backed up server.cjs to: $serverBak" }

$serverRaw = Get-Content $serverPath -Raw -Encoding UTF8

# Hard rule: server.cjs must NOT reference puzzles.json
if ($serverRaw -match "puzzles\.json") {
  Write-Host "Found 'puzzles.json' reference in server.cjs. Rewriting to index.json..."
  $serverRaw = $serverRaw -replace "puzzles\.json", "index.json"
}

# Also enforce the canonical joinPath pattern if possible (best-effort, safe)
# If it already uses index.json, we leave it. If it uses some other puzzles filename, we don't blindly rewrite.
# We only ensure NO puzzles.json remains.
Set-Content -Path $serverPath -Value $serverRaw -Encoding UTF8
Write-Host "Policy A enforced: server.cjs contains puzzles.json? " -NoNewline
if ((Get-Content $serverPath -Raw -Encoding UTF8) -match "puzzles\.json") { throw "FAIL: server.cjs still references puzzles.json" } else { Write-Host "NO" }

# ---- 2) Quarantine puzzles.json (if present) ----
Write-Host "`n=== 2) Quarantine backend/src/puzzles/puzzles.json (Option 1) ==="
if (-not (Test-Path $legacyDir)) {
  New-Item -ItemType Directory -Force -Path $legacyDir | Out-Null
  Write-Host "Created: $legacyDir"
}

if (Test-Path $puzzlesPath) {
  $puzzlesBak = Backup-File $puzzlesPath $backendBackupDir
  if ($puzzlesBak) { Write-Host "Backed up puzzles.json to: $puzzlesBak" }

  # Validate it parses in PowerShell before moving (strict enough)
  Write-Host "Validating puzzles.json parses (PowerShell ConvertFrom-Json)..."
  $raw = Get-Content $puzzlesPath -Raw -Encoding UTF8
  try { $null = $raw | ConvertFrom-Json } catch { throw "puzzles.json is not valid JSON: $($_.Exception.Message)" }

  Move-Item -Force -Path $puzzlesPath -Destination $legacyPuzzlesPath
  Write-Host "Moved -> $legacyPuzzlesPath"
} else {
  Write-Host "No puzzles.json found at runtime location (OK). Nothing to move."
}

# Write a small README so humans don’t “bring it back” accidentally
$readme = @"
# _legacy puzzles.json (NOT USED AT RUNTIME)

Policy A: The backend loads puzzles ONLY from:
- backend/src/puzzles/index.json

This folder stores older/reference puzzle sources.
Do not reintroduce runtime reads of puzzles.json without an explicit plan + tests.
"@
Set-Content -Path $legacyReadmePath -Value $readme -Encoding UTF8
Write-Host "Wrote: $legacyReadmePath"

# ---- 3) Sanity: index.json must parse and be an array ----
Write-Host "`n=== 3) Sanity check index.json schema ==="
$indexRaw = Get-Content $indexPath -Raw -Encoding UTF8
try { $indexObj = $indexRaw | ConvertFrom-Json } catch { throw "index.json is not valid JSON: $($_.Exception.Message)" }

if ($indexObj -isnot [System.Array]) {
  throw "index.json must be a JSON array. Current type: $($indexObj.GetType().FullName)"
}
if ($indexObj.Count -lt 1) {
  throw "index.json array is empty. Need at least 1 puzzle."
}
Write-Host "index.json OK: array count = $($indexObj.Count)"

# ---- 4) Add a backend test that prevents regression ----
Write-Host "`n=== 4) Add regression test: backend must not use puzzles.json ==="
if (-not (Test-Path $backendTestsDir)) { New-Item -ItemType Directory -Force -Path $backendTestsDir | Out-Null }

$testContent = @"
const fs = require('fs');
const path = require('path');

test('Policy A: backend must not reference puzzles.json at runtime', () => {
  const serverPath = path.join(__dirname, '..', 'src', 'server.cjs');
  const raw = fs.readFileSync(serverPath, 'utf8');
  expect(raw.includes('puzzles.json')).toBe(false);
});

test('Policy A: index.json must exist (runtime source of truth)', () => {
  const indexPath = path.join(__dirname, '..', 'src', 'puzzles', 'index.json');
  expect(fs.existsSync(indexPath)).toBe(true);
});
"@
Set-Content -Path $policyTestPath -Value $testContent -Encoding UTF8
Write-Host "Wrote: $policyTestPath"

# ---- 5) Backend test run (sanity) ----
Write-Host "`n=== 5) Backend tests (sanity) ==="
Set-Location $backendDir
Write-Host "In: $(Get-Location)"
npm test

# ---- Golden Rule: return to root ----
Set-Location $ROOT
Write-Host "`n== PATCH COMPLETE. Returned to: $(Get-Location) =="
