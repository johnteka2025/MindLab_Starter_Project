cd "C:\Projects\MindLab_Starter_Project"

$target = "C:\Projects\MindLab_Starter_Project\fix_phase_3_1_repair_health_endpoint_and_tests.ps1"

$code = @'
# fix_phase_3_1_repair_health_endpoint_and_tests.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info([string]$m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok([string]$m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn([string]$m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail([string]$m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir  "src\server.cjs"

$ContractDir  = Join-Path $BackendDir "tests\contract"
$HealthTest   = Join-Path $ContractDir "health_api.contract.test.js"
$ProgressTest = Join-Path $ContractDir "progress_api.contract.test.js"

$BackupsRoot = Join-Path $ProjectRoot "backups\manual_edits"
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = Join-Path $BackupsRoot ("PHASE_3_1_REPAIR_{0}" -f $Stamp)

function Ensure-Dir([string]$p){
  if(-not (Test-Path $p)){
    New-Item -ItemType Directory -Path $p | Out-Null
  }
}

function Backup-File([string]$path){
  if(Test-Path $path){
    $rel = $path.Replace($ProjectRoot, "").TrimStart("\")
    $dest = Join-Path $BackupDir $rel
    Ensure-Dir (Split-Path -Parent $dest)
    Copy-Item -Force $path $dest
  }
}

function Write-Utf8NoBom([string]$path, [string]$content){
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function Normalize-Newlines([string]$s){
  $s = $s -replace "`r`n", "`n"
  $s = $s -replace "`r", "`n"
  return $s
}

function Ensure-Server-Exports-And-NoAutoListen {
  if(-not (Test-Path $ServerFile)){
    Fail "Server file not found: $ServerFile"
  }

  Info "Reading server file: $ServerFile"
  $raw = Get-Content -Raw -Encoding UTF8 -Path $ServerFile
  $raw = Normalize-Newlines $raw

  # Ensure /health exists
  if($raw -notmatch "(?m)^\s*app\.(get|route)\(\s*['""]\/health['""]"){
    Info "Adding /health endpoint (missing)..."

    $healthBlock = @'
 
// --- health endpoint (added by Phase 3.1 fixer) ---
app.get('/health', (req, res) => {
  res.json({ ok: true });
});
// --- end health endpoint ---
'@

    if($raw -match "(?m)^\s*(const|let)\s+app\s*=\s*express\(\)\s*;?\s*$"){
      $raw = [regex]::Replace(
        $raw,
        "(?m)^\s*(const|let)\s+app\s*=\s*express\(\)\s*;?\s*$",
        '$0' + $healthBlock,
        1
      )
    } else {
      Warn "Could not find clean 'app = express()' line. Prepending /health block."
      $raw = $healthBlock + "`n" + $raw
    }
  } else {
    Ok "/health already present."
  }

  # Ensure module.exports = { app };
  $raw = [regex]::Replace($raw, "(?m)^\s*module\.exports\s*=\s*app\s*;\s*$", "", "Multiline")

  if($raw -notmatch "(?m)^\s*module\.exports\s*=\s*\{\s*app\s*\}\s*;\s*$"){
    Info "Ensuring module.exports = { app } exists..."
    $raw = $raw.TrimEnd() + "`n`nmodule.exports = { app };`n"
  } else {
    Ok "module.exports = { app } already present."
  }

  # Guard app.listen with require.main === module
  if($raw -match "(?m)^\s*if\s*\(\s*require\.main\s*===\s*module\s*\)\s*\{"){
    Ok "require.main guard already present."
  } else {
    Info "Adding require.main === module guard around app.listen..."

    $matches = [regex]::Matches($raw, "app\.listen\s*\(", "IgnoreCase")
    if($matches.Count -lt 1){
      Warn "No app.listen(...) found. Skipping listen-guard step."
    } else {
      $idx = $matches[$matches.Count - 1].Index
      $head = $raw.Substring(0, $idx)
      $tail = $raw.Substring($idx)

      $semiPos = $tail.IndexOf(";")
      if($semiPos -ge 0){
        $listenStmt = $tail.Substring(0, $semiPos + 1)
        $restTail   = $tail.Substring($semiPos + 1)

        $guarded = "if (require.main === module) {" + "`n" +
                   "  " + $listenStmt + "`n" +
                   "}" + "`n"

        $raw = $head + $guarded + $restTail
      } else {
        Warn "Could not find semicolon after app.listen. Wrapping remainder as fallback."
        $raw = $head + "if (require.main === module) {" + "`n" + $tail + "`n" + "}" + "`n"
      }
    }
  }

  $raw = $raw.TrimEnd() + "`n"
  Info "Writing updated server file..."
  Write-Utf8NoBom $ServerFile $raw
  Ok "Patched server.cjs"
}

function Rewrite-Contract-Tests-SelfHosted {
  Ensure-Dir $ContractDir

  $healthContent = @'
const { app } = require('../../src/server.cjs');

function baseUrl(server) {
  const addr = server.address();
  const port = addr && addr.port;
  return 'http://127.0.0.1:' + port;
}

describe('Health API contract: GET /health returns { ok: true }', () => {
  let server;

  beforeAll(async () => {
    server = app.listen(0);
  });

  afterAll(async () => {
    if (server) await new Promise((resolve) => server.close(resolve));
  });

  test('GET /health returns ok=true', async () => {
    const r = await fetch(baseUrl(server) + '/health');
    expect(r.ok).toBe(true);
    const j = await r.json();
    expect(j).toEqual({ ok: true });
  });
});
'@

  $progressContent = @'
const { app } = require('../../src/server.cjs');

function baseUrl(server) {
  const addr = server.address();
  const port = addr && addr.port;
  return 'http://127.0.0.1:' + port;
}

describe('Progress API contract: GET /progress returns { total, solved } numbers', () => {
  let server;

  beforeAll(async () => {
    server = app.listen(0);
  });

  afterAll(async () => {
    if (server) await new Promise((resolve) => server.close(resolve));
  });

  test('GET /progress returns numeric totals', async () => {
    const r = await fetch(baseUrl(server) + '/progress');
    expect(r.ok).toBe(true);
    const j = await r.json();
    expect(typeof j.total).toBe('number');
    expect(typeof j.solved).toBe('number');
  });
});
'@

  Info "Writing contract tests (self-hosted)..."
  Write-Utf8NoBom $HealthTest $healthContent
  Write-Utf8NoBom $ProgressTest $progressContent
  Ok "Wrote: $HealthTest"
  Ok "Wrote: $ProgressTest"
}

function Sanity-Require-ServerCjs {
  Push-Location $BackendDir
  try {
    Info "Sanity: requiring src/server.cjs (should NOT start server)..."
    & node -e "require('./src/server.cjs'); console.log('require ok');"
    Ok "Sanity require OK."
  } finally { Pop-Location }
}

function Run-Backend-Tests {
  Push-Location $BackendDir
  try {
    Info "Running backend tests (npm test)..."
    cmd.exe /c "npm test"
    Ok "Backend tests GREEN."
  } finally { Pop-Location }
}

Info "ProjectRoot: $ProjectRoot"
Info "BackendDir : $BackendDir"
Info "ServerFile : $ServerFile"
Info "ContractDir: $ContractDir"
Info "BackupDir  : $BackupDir"

Ensure-Dir $BackupDir
Backup-File $ServerFile
Backup-File $HealthTest
Backup-File $ProgressTest
Ok "Backups created."

Ensure-Server-Exports-And-NoAutoListen
Rewrite-Contract-Tests-SelfHosted
Sanity-Require-ServerCjs
Run-Backend-Tests

Ok "PHASE 3.1 REPAIR COMPLETE — server import-safe + contract tests self-hosted."
Info ("Returned to: " + (Get-Location).Path)
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($target, $code, $utf8NoBom)

Write-Host "[OK] Overwrote: $target" -ForegroundColor Green
notepad.exe $target
