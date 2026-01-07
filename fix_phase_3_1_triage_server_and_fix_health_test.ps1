# fix_phase_3_1_triage_server_and_fix_health_test.ps1
# Golden Rule: backup -> isolate -> smallest fix -> verify GREEN

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function Ensure-Dir($p){
  if(!(Test-Path $p)){ New-Item -ItemType Directory -Force -Path $p | Out-Null }
}

function Backup-File($src, $backupDir, $tag){
  if(!(Test-Path $src)){ Fail "File not found: $src" }
  Ensure-Dir $backupDir
  $name = Split-Path $src -Leaf
  $dst = Join-Path $backupDir ("{0}.{1}" -f $name, $tag)
  Copy-Item $src $dst -Force
  Ok "Backup created: $dst"
  return $dst
}

function Show-Context($path, [int]$line, [int]$radius=8){
  if(!(Test-Path $path)){ return }
  $lines = Get-Content -Path $path -Encoding UTF8
  $start = [Math]::Max(1, $line - $radius)
  $end   = [Math]::Min($lines.Count, $line + $radius)
  Write-Host ""
  Write-Host "---- Context: $path (L$start..L$end) ----" -ForegroundColor Magenta
  for($i=$start; $i -le $end; $i++){
    "{0,5}: {1}" -f $i, $lines[$i-1]
  }
  Write-Host "----------------------------------------" -ForegroundColor Magenta
  Write-Host ""
}

function Node-Check($file){
  $out = & node --check $file 2>&1 | Out-String
  $ok = $LASTEXITCODE -eq 0
  $line = 0
  if($out -match ":\s*(\d+)\s*$"){ $line = [int]$matches[1] }
  elseif($out -match ":\s*(\d+):(\d+)"){ $line = [int]$matches[1] }
  return [pscustomobject]@{ Ok=$ok; Raw=$out.Trim(); Line=$line }
}

function Run-CmdCapture([string]$workingDir, [string]$command){
  Push-Location $workingDir
  try{
    # Use cmd.exe so stderr doesn't become a PowerShell error record.
    $out = & cmd.exe /c "$command 2>&1" | Out-String
    $code = $LASTEXITCODE
    return [pscustomobject]@{ ExitCode=$code; Output=$out.Trim() }
  } finally {
    Pop-Location
  }
}

function Require-Check($backendDir){
  # Hardened: capture *all* output even if node writes to stderr.
  $js = @"
process.on('uncaughtException', (e) => { console.error(e && e.stack ? e.stack : e); process.exit(1); });
process.on('unhandledRejection', (e) => { console.error(e && e.stack ? e.stack : e); process.exit(1); });
process.env.NODE_ENV = 'test';
const m = require('./src/server.cjs');
const keys = m ? Object.keys(m) : [];
console.log('OK_REQUIRE', keys.join(','));
"@.Replace("`r`n"," ")

  $cmd = "node -e ""$js"""
  $r = Run-CmdCapture $backendDir $cmd
  if($r.ExitCode -ne 0){
    return [pscustomobject]@{ Ok=$false; Raw=$r.Output }
  }
  if($r.Output -notmatch "OK_REQUIRE"){
    return [pscustomobject]@{ Ok=$false; Raw=$r.Output }
  }
  return [pscustomobject]@{ Ok=$true; Raw=$r.Output }
}

function Write-Utf8NoBom($path, $content){
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

# ----------------- Paths -----------------
$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir "src\server.cjs"
$HealthTest  = Join-Path $BackendDir "tests\contract\health_api_contract.test.js"
$BackupsRoot = Join-Path $ProjectRoot "backups\manual_edits"
$NowStamp    = (Get-Date).ToString("yyyyMMdd_HHmmss")
$BackupDir   = Join-Path $BackupsRoot ("PHASE_3_1_TRIAGE_{0}" -f $NowStamp)

Info "ProjectRoot : $ProjectRoot"
Info "BackendDir  : $BackendDir"
Info "ServerFile  : $ServerFile"
Info "HealthTest  : $HealthTest"
Info "BackupDir   : $BackupDir"

if(!(Test-Path $BackendDir)){ Fail "BackendDir not found: $BackendDir" }
if(!(Get-Command node -ErrorAction SilentlyContinue)){ Fail "node not found on PATH." }
if(!(Get-Command npm  -ErrorAction SilentlyContinue)){ Fail "npm not found on PATH." }

# ----------------- Backups first -----------------
Backup-File $ServerFile $BackupDir "SERVER.CURRENT.BEFORE"
if(Test-Path $HealthTest){
  Backup-File $HealthTest $BackupDir "HEALTH_TEST.CURRENT.BEFORE"
} else {
  Warn "Health test not found yet (will create): $HealthTest"
}

# ----------------- Step A: Syntax check server.cjs -----------------
Info "Checking JS syntax: node --check src/server.cjs"
$check = Node-Check $ServerFile
if($check.Ok){
  Ok "server.cjs passes node --check."
} else {
  Warn "server.cjs FAILS node --check. Output:"
  Write-Host $check.Raw -ForegroundColor Yellow
  if($check.Line -gt 0){ Show-Context $ServerFile $check.Line 10 }
  Fail "server.cjs is syntactically invalid. Fix server.cjs first."
}

# ----------------- Step B: Require() check (hardened) -----------------
Info "Checking require() load safely (captures stderr): require('./src/server.cjs')"
$req = Require-Check $BackendDir
if($req.Ok){
  Ok "server.cjs require() check OK."
  Info $req.Raw
} else {
  Warn "server.cjs require() check FAILED. Full output:"
  Write-Host $req.Raw -ForegroundColor Yellow
  Fail "Stop here: server.cjs must require() cleanly before contract tests can run."
}

# ----------------- Step C: Rewrite health_api_contract.test.js (NO node-fetch) -----------------
Info "Writing a clean, self-contained health contract test (uses Node 22 global fetch)."
Ensure-Dir (Split-Path $HealthTest -Parent)

$healthContent = @"
/**
 * Contract test: GET /health returns { ok: true }
 * Self-hosted; uses Node 18+ built-in fetch (Node 22 in your env). No node-fetch dependency.
 */
const http = require('http');

function startServer(app) {
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
  if (!r.ok) throw new Error(`GET failed: ${r.status} ${r.statusText}`);
  return await r.json();
}

describe('Health API contract', () => {
  let server;
  let baseUrl;

  beforeAll(async () => {
    const mod = require('../../src/server.cjs');
    const app = (mod && mod.app) ? mod.app : mod;
    if (!app) throw new Error('server.cjs did not export app. Expected module.exports = { app } or module.exports = app');
    const started = await startServer(app);
    server = started.server;
    baseUrl = started.baseUrl;
  });

  afterAll(async () => {
    if (server) await new Promise((res) => server.close(res));
  });

  test('GET /health returns { ok: true }', async () => {
    const body = await getJson(`${baseUrl}/health`);
    expect(body).toHaveProperty('ok', true);
  });
});
"@

Write-Utf8NoBom $HealthTest $healthContent
Ok "Wrote: $HealthTest"

Info "Quick syntax check for the test file (node --check)."
$tc = Node-Check $HealthTest
if(-not $tc.Ok){
  Warn $tc.Raw
  if($tc.Line -gt 0){ Show-Context $HealthTest $tc.Line 10 }
  Fail "health_api_contract.test.js is still syntactically invalid."
}
Ok "health_api_contract.test.js passes node --check."

# ----------------- Step D: Run backend tests only -----------------
Info "Running backend tests only (npm test)..."
Push-Location $BackendDir
try{
  cmd.exe /c "npm test"
  if($LASTEXITCODE -ne 0){
    Fail "Backend npm test failed (exit=$LASTEXITCODE)."
  }
  Ok "Backend tests GREEN."
} finally {
  Pop-Location
}

Ok "PHASE 3.1 TRIAGE COMPLETE - server.cjs require-safe + health contract test fixed."
Info "Returned to: $((Get-Location).Path)"
