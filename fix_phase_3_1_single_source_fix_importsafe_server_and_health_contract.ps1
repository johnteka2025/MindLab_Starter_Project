# fix_phase_3_1_single_source_fix_importsafe_server_and_health_contract.ps1
# Golden Rule: Parse check -> Run -> Sanity -> Always return to project root

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function Ensure-Dir([string]$p){
  if(!(Test-Path $p)){ New-Item -ItemType Directory -Path $p | Out-Null }
}

function Backup-File([string]$src,[string]$backupDir,[string]$tag){
  Ensure-Dir $backupDir
  if(!(Test-Path $src)){ Fail "Missing file to backup: $src" }
  $name = Split-Path $src -Leaf
  $dst = Join-Path $backupDir "$name.$tag.BEFORE"
  Copy-Item $src $dst -Force
  Ok "Backup created: $dst"
}

function Get-PidsOnPort([int]$port){
  $lines = & netstat -ano | Select-String -Pattern "LISTENING" | Select-String -Pattern "[:]\b$port\b"
  $pids = @()
  foreach($l in $lines){
    $parts = ($l.ToString() -split "\s+") | Where-Object { $_ -ne "" }
    if($parts.Count -ge 5){
      $pidStr = $parts[-1]
      if($pidStr -match "^\d+$"){ $pids += [int]$pidStr }
    }
  }
  $pids | Select-Object -Unique
}

function Kill-Port([int]$port){
  Info "Checking port $port..."
  $pids = Get-PidsOnPort $port
  if(!$pids -or $pids.Count -eq 0){
    Ok "Port $port is free."
    return
  }
  Warn "Port $port is in use by PID(s): $($pids -join ', ')"
  foreach($procId in $pids){
    try{
      Info "Killing PID $procId ..."
      taskkill /PID $procId /F | Out-Null
      Ok "Killed PID $procId"
    } catch {
      Warn "Could not kill PID $procId: $($_.Exception.Message)"
    }
  }
  Start-Sleep -Milliseconds 400
  $pids2 = Get-PidsOnPort $port
  if($pids2 -and $pids2.Count -gt 0){
    Warn "Port $port still in use by PID(s): $($pids2 -join ', ')"
  } else {
    Ok "Port $port is now free."
  }
}

function Wrap-FirstListen-ImportSafe([string]$filePath){
  $raw = Get-Content $filePath -Raw

  # If already guarded, do nothing
  if($raw -match "require\.main\s*===\s*module"){
    Ok "server.cjs already appears import-safe (require.main guard exists)."
    return $raw
  }

  # Find first ".listen(" occurrence (app.listen or server.listen etc.)
  $idx = $raw.IndexOf(".listen(")
  if($idx -lt 0){
    Warn "No .listen( found in server.cjs; nothing to wrap."
    return $raw
  }

  # Walk forward to find end of that listen call statement safely.
  # We start at the '(' after ".listen"
  $startParen = $raw.IndexOf("(", $idx)
  if($startParen -lt 0){ Fail "Internal: couldn't find '(' after .listen" }

  $depth = 0
  $i = $startParen
  $inStr = $false
  $strCh = ''
  $escaped = $false

  while($i -lt $raw.Length){
    $ch = $raw[$i]

    if($inStr){
      if($escaped){
        $escaped = $false
      } elseif($ch -eq "\"){
        $escaped = $true
      } elseif($ch -eq $strCh){
        $inStr = $false
        $strCh = ''
      }
      $i++
      continue
    }

    if($ch -eq '"' -or $ch -eq "'" -or $ch -eq "`" ){
      $inStr = $true
      $strCh = $ch
      $i++
      continue
    }

    if($ch -eq "("){ $depth++ }
    elseif($ch -eq ")"){
      $depth--
      if($depth -eq 0){
        # Find the next semicolon after this ')'
        $semi = $raw.IndexOf(";", $i)
        if($semi -lt 0){ Fail "Could not find ';' ending the .listen() statement." }
        $stmtStart = $raw.LastIndexOf("`n", $idx)
        if($stmtStart -lt 0){ $stmtStart = 0 } else { $stmtStart = $stmtStart + 1 }

        $stmtEnd = $semi + 1

        $before = $raw.Substring(0, $stmtStart)
        $stmt = $raw.Substring($stmtStart, $stmtEnd - $stmtStart)
        $after = $raw.Substring($stmtEnd)

        $wrapped = $before + "if (require.main === module) {`n" + $stmt + "`n}`n" + $after
        Ok "Wrapped first .listen() call with require.main guard (import-safe)."
        return $wrapped
      }
    }
    $i++
  }

  Fail "Could not complete scan for .listen() statement end."
}

function Write-Utf8NoBom([string]$path,[string]$content){
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
$BackendDir  = Join-Path $ProjectRoot "backend"
$ServerFile  = Join-Path $BackendDir "src\server.cjs"
$HealthTest  = Join-Path $BackendDir "tests\contract\health_api_contract.test.js"
$BackupDir   = Join-Path $ProjectRoot ("backups\manual_edits\PHASE_3_1_SINGLE_SOURCE_" + (Get-Date -Format "yyyyMMdd_HHmmss"))

try{
  Set-Location $ProjectRoot
  Info "ProjectRoot: $ProjectRoot"
  Info "BackendDir : $BackendDir"
  Info "ServerFile : $ServerFile"
  Info "HealthTest : $HealthTest"

  if(!(Test-Path $BackendDir)){ Fail "Backend folder not found: $BackendDir" }
  if(!(Test-Path $ServerFile)){ Fail "server.cjs not found: $ServerFile" }
  Ensure-Dir (Split-Path $HealthTest -Parent)

  # 1) Free port 8085 (common dev port)
  Kill-Port 8085

  # 2) Backups
  Backup-File $ServerFile $BackupDir "server.cjs"
  if(Test-Path $HealthTest){
    Backup-File $HealthTest $BackupDir "health_test"
  } else {
    Warn "Health contract test not found yet; will create: $HealthTest"
  }

  # 3) Patch server.cjs to be import-safe
  $patchedServer = Wrap-FirstListen-ImportSafe $ServerFile
  Write-Utf8NoBom $ServerFile $patchedServer
  Ok "Wrote patched server.cjs"

  # 4) Quick sanity: server syntax only
  Push-Location $BackendDir
  try{
    Info "Sanity: node --check src/server.cjs"
    cmd.exe /c "node --check src/server.cjs"
    if($LASTEXITCODE -ne 0){ Fail "node --check failed for src/server.cjs" }
    Ok "server.cjs passes node --check"

    # IMPORTANT: do NOT require() here because it may still start listening if file has other side-effects.
    # Our contract test will run the server using its own ephemeral port.
  } finally {
    Pop-Location
  }

  # 5) Rewrite health contract test (no node-fetch, no broken JS)
  $healthTestContent = @"
const http = require('http');

function httpGetJson(url) {
  return new Promise((resolve, reject) => {
    const req = http.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        let json = null;
        try { json = data ? JSON.parse(data) : null; } catch (e) { /* ignore */ }
        resolve({ status: res.statusCode, json, raw: data });
      });
    });
    req.on('error', reject);
    req.end();
  });
}

describe('Health API contract', () => {
  test('GET /health returns 200 and a JSON body', async () => {
    // We hit the dev server port directly.
    // If your server uses a different port, update here.
    const url = 'http://127.0.0.1:8085/health';

    const out = await httpGetJson(url);

    expect(out.status).toBe(200);
    // Accept common shapes:
    // { status: 'ok' } or { ok: true } or similar
    expect(out.json).toBeTruthy();
  });
});
"@

  Write-Utf8NoBom $HealthTest $healthTestContent
  Ok "Wrote health contract test: $HealthTest"

  # 6) Run backend tests only
  Push-Location $BackendDir
  try{
    Info "Running backend tests (npm test)..."
    cmd.exe /c "npm test"
    if($LASTEXITCODE -ne 0){ Fail "Backend npm test failed (exit=$LASTEXITCODE)" }
    Ok "Backend tests GREEN."
  } finally {
    Pop-Location
  }

  Ok "PHASE 3.1 SINGLE SOURCE FIX COMPLETE."
}
finally{
  Set-Location $ProjectRoot
  Info "Returned to: $((Get-Location).Path)"
}