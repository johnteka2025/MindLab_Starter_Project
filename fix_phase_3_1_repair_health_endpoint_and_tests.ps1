# fix_phase_3_1_repair_health_endpoint_and_tests.ps1
# Goal: restore known-good files, apply minimal /health + export app, fix health contract test, run sanity + tests.
# Golden Rules: full paths, backups, parse-first, deterministic edits, sanity checks.

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function Ensure-Dir([string]$p){
  if(-not (Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null }
}

function Write-Utf8NoBom([string]$path, [string]$content){
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function Backup-File([string]$src, [string]$backupRoot, [string]$tag){
  Ensure-Dir $backupRoot
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $destDir = Join-Path $backupRoot "${tag}_${ts}"
  Ensure-Dir $destDir
  $name = Split-Path $src -Leaf
  $dest = Join-Path $destDir $name
  Copy-Item -LiteralPath $src -Destination $dest -Force
  Ok "Backup created: $dest"
}

function Restore-Latest-BEFORE([string]$beforeFileName, [string]$destPath, [string]$manualEditsDir){
  # Find newest matching *.BEFORE under backups\manual_edits\PHASE_3_1_REPAIR_*\...
  $candidates = Get-ChildItem -Path $manualEditsDir -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ieq $beforeFileName } |
    Sort-Object LastWriteTime -Descending

  if($candidates -and $candidates.Count -gt 0){
    $src = $candidates[0].FullName
    Copy-Item -LiteralPath $src -Destination $destPath -Force
    Ok "Restored from backup: $src -> $destPath"
    return $true
  }

  Warn "No backup found for $beforeFileName under $manualEditsDir (skipping restore)."
  return $false
}

# ---------------------------
# Paths (FULL, explicit)
# ---------------------------
$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir "src\server.cjs"
$ContractDir = Join-Path $BackendDir "tests\contract"
$HealthTest  = Join-Path $ContractDir "health_api_contract.test.js"
$BackupRoot  = Join-Path $ProjectRoot "backups\manual_edits"
$ManualEdits = $BackupRoot  # convenience

Info "ProjectRoot : $ProjectRoot"
Info "BackendDir  : $BackendDir"
Info "ServerFile  : $ServerFile"
Info "HealthTest  : $HealthTest"

if(-not (Test-Path $ProjectRoot)) { Fail "Project root not found: $ProjectRoot" }
if(-not (Test-Path $BackendDir))  { Fail "Backend folder not found: $BackendDir" }
if(-not (Test-Path $ServerFile))  { Fail "server.cjs not found: $ServerFile" }

Ensure-Dir $ContractDir

# ---------------------------
# 1) Pre-backup current state
# ---------------------------
Backup-File -src $ServerFile -backupRoot $BackupRoot -tag "PHASE_3_1_REPAIR_PRE"
if(Test-Path $HealthTest){
  Backup-File -src $HealthTest -backupRoot $BackupRoot -tag "PHASE_3_1_REPAIR_PRE"
}

# ---------------------------
# 2) Restore last-known-good BEFORE if present
# ---------------------------
# These filenames match how your earlier scripts saved backups.
Restore-Latest-BEFORE -beforeFileName "server.cjs.BEFORE" -destPath $ServerFile -manualEditsDir $ManualEdits | Out-Null
Restore-Latest-BEFORE -beforeFileName "health_api_contract.test.js.BEFORE" -destPath $HealthTest -manualEditsDir $ManualEdits | Out-Null

# ---------------------------
# 3) Patch server.cjs (minimal + safe)
#    - Ensure /health exists
#    - Ensure module.exports = { app }
#    - DO NOT try to restructure the whole file (avoid regex disasters)
# ---------------------------
Info "Patching server.cjs (minimal changes only)..."
$raw = Get-Content -Raw -LiteralPath $ServerFile -Encoding UTF8

# Heuristic: find app creation line, then insert /health after it if missing
$hasHealth = $raw -match "(?m)app\.get\(['""]\/health['""]"
if(-not $hasHealth){
  $healthBlock = @"
app.get('/health', (req, res) => {
  res.status(200).json({ ok: true });
});

"@

  # Insert after first occurrence of: app = express()
  if($raw -match "(?m)^\s*(const|let)\s+app\s*=\s*express\(\)\s*;?\s*$"){
    $raw = [regex]::Replace(
      $raw,
      "(?m)^\s*(const|let)\s+app\s*=\s*express\(\)\s*;?\s*$",
      { param($m) $m.Value + "`r`n`r`n" + $healthBlock.TrimEnd() },
      1
    )
    Ok "Inserted /health block after app = express()"
  } else {
    # If app line not found, prepend (still deterministic)
    Warn "Could not find 'app = express()' line. Prepending /health block near top."
    $raw = $healthBlock + "`r`n" + $raw
  }
} else {
  Ok "/health already present (no change)."
}

# Ensure module.exports = { app };
$hasExport = $raw -match "(?m)^\s*module\.exports\s*=\s*\{\s*app\s*\}\s*;?\s*$"
if(-not $hasExport){
  # Put export near end of file, before any require.main guard if present
  if($raw -match "(?m)^\s*if\s*\(\s*require\.main\s*===\s*module\s*\)\s*\{"){
    $raw = [regex]::Replace(
      $raw,
      "(?m)^\s*if\s*\(\s*require\.main\s*===\s*module\s*\)\s*\{",
      "module.exports = { app };`r`n`r`nif (require.main === module) {",
      1
    )
    Ok "Inserted module.exports = { app } before require.main guard."
  } else {
    $raw = $raw.TrimEnd() + "`r`n`r`nmodule.exports = { app };`r`n"
    Ok "Appended module.exports = { app } at end."
  }
} else {
  Ok "module.exports = { app } already present (no change)."
}

Write-Utf8NoBom -path $ServerFile -content $raw
Ok "Wrote patched server.cjs: $ServerFile"

# ---------------------------
# 4) Overwrite health_api_contract.test.js with known-good JS
# ---------------------------
Info "Writing health_api_contract.test.js (known-good syntax)..."
$healthTestContent = @"
const http = require('http');

// IMPORTANT:
// - We import { app } so server.cjs must not auto-listen on require().
// - If server.cjs has require.main guard (recommended), this is safe.
const { app } = require('../../src/server.cjs');

function startServer() {
  return new Promise((resolve, reject) => {
    const server = http.createServer(app);

    server.listen(0, '127.0.0.1', () => {
      const addr = server.address();
      const baseUrl = `http://127.0.0.1:${addr.port}`;
      resolve({ server, baseUrl });
    });

    server.on('error', reject);
  });
}

async function getJson(url) {
  const r = await fetch(url);
  if (!r.ok) {
    throw new Error(`GET failed: ${r.status} ${r.statusText}`);
  }
  return await r.json();
}

describe('Health API contract', () => {
  let server;
  let baseUrl;

  beforeAll(async () => {
    const started = await startServer();
    server = started.server;
    baseUrl = started.baseUrl;
  });

  afterAll(async () => {
    if (!server) return;
    await new Promise((resolve) => server.close(resolve));
  });

  test('GET /health returns ok:true', async () => {
    const json = await getJson(`${baseUrl}/health`);
    expect(json).toEqual({ ok: true });
  });
});
"@

Write-Utf8NoBom -path $HealthTest -content $healthTestContent
Ok "Wrote: $HealthTest"

# ---------------------------
# 5) Sanity: require server.cjs
# ---------------------------
Info "Sanity: node -e require('./src/server.cjs') (should not crash)..."
Push-Location $BackendDir
try{
  cmd.exe /c "node -e ""require('./src/server.cjs')"""
  Ok "Sanity require OK."
} finally {
  Pop-Location
}

# ---------------------------
# 6) Run backend tests (targeted first, then full)
# ---------------------------
Push-Location $BackendDir
try{
  Info "Running targeted test: health_api_contract.test.js"
  cmd.exe /c "npm test -- --runInBand tests/contract/health_api_contract.test.js"
  Ok "Targeted health contract test GREEN."

  Info "Running full backend tests (npm test)..."
  cmd.exe /c "npm test"
  Ok "Backend tests GREEN."
} finally {
  Pop-Location
}

Ok "PHASE 3.1 REPAIR COMPLETE - /health + export app + health contract test fixed."
Info ("Returned to: " + (Get-Location).Path)
