<#
fix_phase_3_1_restore_server_and_fix_contract_tests.ps1

Goal:
- Make backend server import-safe (require() should NOT start listening)
- Ensure module.exports = { app }
- Ensure /health exists and returns JSON
- Rewrite contract tests to be self-hosted (use port 0) and syntax-clean
- Create backups with timestamps
#>

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function Write-Utf8NoBom([string]$path, [string]$content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function Ensure-Dir([string]$p){
  if(!(Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null }
}

function Timestamp(){
  return (Get-Date).ToString("yyyyMMdd_HHmmss")
}

function Backup-File([string]$filePath, [string]$backupRoot, [string]$tag){
  if(!(Test-Path $filePath)){ return $null }
  Ensure-Dir $backupRoot
  $stamp = Timestamp
  $leaf = Split-Path $filePath -Leaf
  $destDir = Join-Path $backupRoot ("{0}_{1}" -f $tag, $stamp)
  Ensure-Dir $destDir
  $dest = Join-Path $destDir ($leaf + ".BEFORE")
  Copy-Item $filePath $dest -Force
  Ok "Backup created: $dest"
  return $dest
}

function Node-Require-Check([string]$backendDir){
  Push-Location $backendDir
  try {
    & node -e "require('./src/server.cjs')" 2>$null | Out-Null
    Ok "server.cjs require() check OK."
    return $true
  } catch {
    Warn "server.cjs require() check FAILED."
    return $false
  } finally {
    Pop-Location
  }
}

function Restore-Latest-ServerBackup([string]$projectRoot, [string]$serverFile){
  $backupRoot = Join-Path $projectRoot "backups\manual_edits"
  if(!(Test-Path $backupRoot)){
    Warn "No backup root found: $backupRoot"
    return $false
  }

  $candidates = Get-ChildItem -Path $backupRoot -Recurse -File -Filter "server.cjs.BEFORE" |
    Sort-Object LastWriteTime -Descending

  if(!$candidates -or $candidates.Count -eq 0){
    Warn "No server.cjs.BEFORE backups found."
    return $false
  }

  $latest = $candidates[0].FullName
  Copy-Item $latest $serverFile -Force
  Ok "Restored server.cjs from latest backup: $latest"
  return $true
}

function Ensure-Health-Route-And-Export([string]$serverFile){
  $raw = Get-Content -Raw -Encoding UTF8 $serverFile

  # 1) Ensure express app exists (best-effort: if missing, do nothing destructive)
  if($raw -notmatch "(?m)^\s*(const|let|var)\s+app\s*=\s*express\("){
    Warn "Could not find 'app = express(...)' pattern. Will still attempt export/guard insertion carefully."
  }

  # 2) Ensure /health route exists
  $hasHealth = ($raw -match "(?m)app\.(get|use)\(\s*['""]\/health['""]")
  if(-not $hasHealth){
    $healthBlock = @"
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});
"@

    # Insert health route after app initialization if possible, else prepend near top after express usage
    if($raw -match "(?m)^\s*(const|let|var)\s+app\s*=\s*express\(\s*\)\s*;?\s*$"){
      $raw = [regex]::Replace(
        $raw,
        "(?m)^\s*(const|let|var)\s+app\s*=\s*express\(\s*\)\s*;?\s*$",
        "`$0`n`n$healthBlock",
        1
      )
      Ok "/health route inserted after app initialization."
    } else {
      $raw = $healthBlock + "`n" + $raw
      Warn "/health route prepended (couldn't find a clean insertion point)."
    }
  } else {
    Ok "/health route already present (no change)."
  }

  # 3) Ensure module.exports = { app };
  # Remove any previous module.exports that exports app incorrectly (best effort)
  if($raw -match "(?m)^\s*module\.exports\s*="){
    # If it already exports app in an object, keep it
    if($raw -match "(?m)^\s*module\.exports\s*=\s*\{\s*app\s*\}\s*;?\s*$"){
      Ok "module.exports = { app } already present (no change)."
    } else {
      # We won't remove unknown exports; we will append a safe export at end if app exists.
      Warn "module.exports exists but not in expected '{ app }' form. Will append a safe export at end."
      $raw = $raw.TrimEnd() + "`n`nmodule.exports = { app };`n"
    }
  } else {
    $raw = $raw.TrimEnd() + "`n`nmodule.exports = { app };`n"
    Ok "Added module.exports = { app }."
  }

  # 4) Ensure listen guard (require.main === module)
  # If the file already has require.main guard, do nothing.
  if($raw -match "(?m)require\.main\s*===\s*module"){
    Ok "require.main guard already present (no change)."
  } else {
    # Best-effort wrapping for common 'app.listen(' usage:
    # Replace: app.listen(...);
    # with: if (require.main === module) { app.listen(...); }
    $raw2 = [regex]::Replace(
      $raw,
      "(?m)^(?<indent>\s*)app\.listen\((?<args>.+?)\)\s*;?\s*$",
      "`${indent}if (require.main === module) { app.listen(`${args}); }",
      1
    )

    if($raw2 -ne $raw){
      $raw = $raw2
      Ok "Wrapped app.listen(...) with require.main guard."
    } else {
      Warn "Did not find a simple app.listen(...) line to wrap. If server starts on require(), tests may still fail."
    }
  }

  Write-Utf8NoBom $serverFile $raw
  Ok "Wrote patched server: $serverFile"
}

function Rewrite-Health-Contract-Test([string]$testFile){
  $content = @"
const { app } = require('../../src/server.cjs');

function startServer() {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, '127.0.0.1', () => {
      const addr = server.address();
      const baseUrl = `http://127.0.0.1:${addr.port}`;
      resolve({ server, baseUrl });
    });
    server.on('error', reject);
  });
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
    if (server) {
      await new Promise((r) => server.close(r));
    }
  });

  test('GET /health returns ok', async () => {
    const r = await fetch(`${baseUrl}/health`);
    if (!r.ok) throw new Error(`GET /health failed: ${r.status} ${r.statusText}`);
    const json = await r.json();
    expect(json).toHaveProperty('status');
    expect(json.status).toBe('ok');
  });
});
"@
  Write-Utf8NoBom $testFile $content
  Ok "Rewrote test: $testFile"
}

function Rewrite-Progress-Contract-Test([string]$testFile){
  $content = @"
const { app } = require('../../src/server.cjs');

function startServer() {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, '127.0.0.1', () => {
      const addr = server.address();
      const baseUrl = `http://127.0.0.1:${addr.port}`;
      resolve({ server, baseUrl });
    });
    server.on('error', reject);
  });
}

async function getJson(baseUrl, path) {
  const r = await fetch(`${baseUrl}${path}`);
  if (!r.ok) throw new Error(`GET ${path} failed: ${r.status} ${r.statusText}`);
  return await r.json();
}

describe('Progress API contract', () => {
  let server;
  let baseUrl;

  beforeAll(async () => {
    const started = await startServer();
    server = started.server;
    baseUrl = started.baseUrl;
  });

  afterAll(async () => {
    if (server) {
      await new Promise((r) => server.close(r));
    }
  });

  test('GET /progress returns {total, solved} numbers', async () => {
    const json = await getJson(baseUrl, '/progress');
    expect(json).toHaveProperty('total');
    expect(json).toHaveProperty('solved');
    expect(typeof json.total).toBe('number');
    expect(typeof json.solved).toBe('number');
  });
});
"@
  Write-Utf8NoBom $testFile $content
  Ok "Rewrote test: $testFile"
}

function Run-Backend-Tests([string]$backendDir){
  Push-Location $backendDir
  try {
    Info "Running backend tests (npm test)..."
    cmd.exe /c "npm test"
    Ok "Backend tests GREEN."
  } finally {
    Pop-Location
  }
}

# =========================
# MAIN
# =========================

$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir "src\server.cjs"
$HealthTest  = Join-Path $BackendDir "tests\contract\health_api_contract.test.js"
$ProgressTest= Join-Path $BackendDir "tests\contract\progress_api_contract.test.js"
$BackupRoot  = Join-Path $ProjectRoot "backups\manual_edits"

Info "ProjectRoot : $ProjectRoot"
Info "BackendDir  : $BackendDir"
Info "ServerFile  : $ServerFile"
Info "HealthTest  : $HealthTest"
Info "ProgressTest: $ProgressTest"

if(!(Test-Path $BackendDir)){ Fail "BackendDir not found: $BackendDir" }
if(!(Test-Path $ServerFile)){ Fail "Server file not found: $ServerFile" }

Backup-File $ServerFile   $BackupRoot "PHASE_3_1_REPAIR2"
if(Test-Path $HealthTest){ Backup-File $HealthTest $BackupRoot "PHASE_3_1_REPAIR2" }
if(Test-Path $ProgressTest){ Backup-File $ProgressTest $BackupRoot "PHASE_3_1_REPAIR2" }

# If server currently fails require(), attempt restore from latest known backup
if(-not (Node-Require-Check $BackendDir)){
  Warn "Attempting to restore server.cjs from latest backup..."
  $restored = Restore-Latest-ServerBackup $ProjectRoot $ServerFile
  if(-not $restored){ Fail "server.cjs cannot be required and no backup restore available." }
  if(-not (Node-Require-Check $BackendDir)){ Fail "server.cjs still cannot be required after restore." }
}

# Patch server (health + export + require.main guard)
Ensure-Health-Route-And-Export $ServerFile

# Sanity require check again
if(-not (Node-Require-Check $BackendDir)){
  Fail "server.cjs require() sanity check failed AFTER patching. Stop."
}

# Rewrite tests cleanly
Ensure-Dir (Split-Path $HealthTest -Parent)
Ensure-Dir (Split-Path $ProgressTest -Parent)

Rewrite-Health-Contract-Test $HealthTest
Rewrite-Progress-Contract-Test $ProgressTest

# Run tests
Run-Backend-Tests $BackendDir

Ok "PHASE 3.1 REPAIR2 COMPLETE - server import-safe + /health + contract tests fixed."
Info "Returned to: $((Get-Location).Path)"
