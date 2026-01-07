# phase_3_1_add_health_endpoint.ps1
# Phase 3.1 â€” Backend/API robustness: add GET /health + contract test (self-contained)

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

# --- Resolve project paths ---
$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir  "src\server.cjs"
$TestDir     = Join-Path $BackendDir  "tests\contract"
$TestFile    = Join-Path $TestDir     "health_api.contract.test.js"
$PkgFile     = Join-Path $BackendDir  "package.json"

Info "ProjectRoot: $ProjectRoot"
Info "BackendDir : $BackendDir"
Info "ServerFile : $ServerFile"
Info "TestFile   : $TestFile"

if (!(Test-Path $ProjectRoot)) { Fail "ProjectRoot not found: $ProjectRoot" }
if (!(Test-Path $BackendDir))  { Fail "BackendDir not found: $BackendDir" }
if (!(Test-Path $ServerFile))  { Fail "Missing server file: $ServerFile" }
if (!(Test-Path $PkgFile))     { Fail "Missing backend package.json: $PkgFile" }

# --- Backups ---
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupRoot = Join-Path $ProjectRoot ("backups\manual_edits\PHASE_3_1_HEALTH_{0}" -f $stamp)
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
Copy-Item -Force $ServerFile (Join-Path $BackupRoot "server.cjs.BEFORE")
Copy-Item -Force $PkgFile    (Join-Path $BackupRoot "package.json.BEFORE")
Ok "Backups in: $BackupRoot"

# --- Patch server.cjs ---
$raw = Get-Content -Raw -Path $ServerFile -Encoding UTF8

# 1) Add /health route (idempotent)
if ($raw -notmatch "(?m)^\s*app\.get\(\s*['""]\/health['""]") {
  # Insert after app creation if possible, otherwise append near top.
  if ($raw -match "(?m)^\s*const\s+app\s*=\s*express\(\)\s*;\s*$") {
    $raw = [regex]::Replace(
      $raw,
      "(?m)^(?<L>\s*const\s+app\s*=\s*express\(\)\s*;\s*)$",
      '${L}' + "`r`n" +
      "app.get('/health', (req, res) => {`r`n" +
      "  const version = process.env.npm_package_version || 'unknown';`r`n" +
      "  res.json({ ok: true, version, env: process.env.NODE_ENV || 'development' });`r`n" +
      "});`r`n",
      1
    )
  }
  else {
    # Fallback: append route near top
    $raw = $raw + "`r`n" +
      "`r`n// --- Added by Phase 3.1 ---`r`n" +
      "app.get('/health', (req, res) => {`r`n" +
      "  const version = process.env.npm_package_version || 'unknown';`r`n" +
      "  res.json({ ok: true, version, env: process.env.NODE_ENV || 'development' });`r`n" +
      "});`r`n"
  }
  Ok "Added GET /health route."
} else {
  Ok "GET /health already present (no change)."
}

# 2) Ensure app.listen only runs when executed directly (so tests can require app safely)
if ($raw -notmatch "require\.main\s*===\s*module") {
  $listenPattern = "app\.listen\([\s\S]*?\);\s*"
  if ($raw -match $listenPattern) {
    $raw = [regex]::Replace(
      $raw,
      $listenPattern,
      "if (require.main === module) {`r`n  `$0`r`n}`r`n",
      1
    )
    Ok "Wrapped app.listen(...) with require.main === module."
  } else {
    Warn "Could not find app.listen(...); nothing wrapped."
  }
} else {
  Ok "require.main gating already present (no change)."
}

# 3) Export app (so tests can import it)
if ($raw -notmatch "(?m)^\s*module\.exports\s*=\s*\{\s*app\s*\}\s*;?\s*$") {
  $raw = $raw.TrimEnd() + "`r`n`r`nmodule.exports = { app };`r`n"
  Ok "Added module.exports = { app }."
} else {
  Ok "module.exports already present (no change)."
}

# Write UTF-8 (no BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($ServerFile, $raw, $utf8NoBom)
Ok "Patched server.cjs"

# --- Ensure test directory exists ---
New-Item -ItemType Directory -Force -Path $TestDir | Out-Null

# --- Write self-contained Jest contract test ---
$testCode = @"
'use strict';

const { app } = require('../../src/server.cjs');

async function getJson(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(`GET failed: ${r.status} ${r.statusText}`);
  return await r.json();
}

describe('Health API contract', () => {
  let server;
  let base;

  beforeAll(() => {
    // Start on an ephemeral port so this test is self-contained and non-flaky.
    server = app.listen(0);
    const port = server.address().port;
    base = `http://127.0.0.1:${port}`;
  });

  afterAll((done) => {
    try {
      server && server.close(() => done());
    } catch (e) {
      done();
    }
  });

  test('GET /health returns {ok, version, env}', async () => {
    const json = await getJson(`${base}/health`);
    expect(json).toHaveProperty('ok', true);
    expect(json).toHaveProperty('version');
    expect(json).toHaveProperty('env');
  });
});
"@

[System.IO.File]::WriteAllText($TestFile, $testCode, $utf8NoBom)
Ok "Wrote test: $TestFile"

# --- Sanity check: requiring server should NOT start listening (due to require.main gate) ---
Push-Location $BackendDir
try {
  Info "Sanity: node require server.cjs (should not start server)..."
  node -e "require('./src/server.cjs'); console.log('require ok')"
  Ok "Sanity require ok."

  Info "Running backend tests (npm test)..."
  cmd.exe /c "npm test"
  Ok "Backend tests GREEN."
}
finally {
  Pop-Location
  Info "Returned to: $((Get-Location).Path)"
}

Ok "PHASE 3.1 COMPLETE â€” /health + self-contained test added."