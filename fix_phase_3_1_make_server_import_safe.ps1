Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

# --- Locate project ---
$ProjectRoot = "C:\Projects\MindLab_Starter_Project"
if(!(Test-Path $ProjectRoot)){ Fail "ProjectRoot not found: $ProjectRoot" }

$BackendDir = Join-Path $ProjectRoot "backend"
$ServerFile = Join-Path $BackendDir "src\server.cjs"

Info "ProjectRoot : $ProjectRoot"
Info "BackendDir  : $BackendDir"
Info "ServerFile  : $ServerFile"

if(!(Test-Path $BackendDir)){ Fail "BackendDir not found: $BackendDir" }
if(!(Test-Path $ServerFile)){ Fail "server.cjs not found: $ServerFile" }

# --- Backup ---
$stamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$backupDir = Join-Path $ProjectRoot "backups\manual_edits\PHASE_3_1_IMPORT_SAFE_$stamp"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
Copy-Item $ServerFile (Join-Path $backupDir "server.cjs.BEFORE") -Force
Ok "Backup created: $backupDir\server.cjs.BEFORE"

# --- Read server.cjs ---
$raw = Get-Content -Raw -Encoding UTF8 $ServerFile

# --- Ensure we export an app safely ---
# Strategy:
# 1) If file already has `module.exports = ...` we normalize it to `module.exports = { app };`
# 2) If file calls app.listen(...) at top level, we wrap that block in:
#    if (require.main === module) { ... }
# 3) If file uses `const app = express();` we assume app exists and export it.

# Normalize any module.exports line
$raw = [regex]::Replace($raw, "(?m)^\s*module\.exports\s*=\s*.*?;\s*$", "", "Multiline")

# Try to detect a top-level listen call. We will wrap any `app.listen(` occurrence not already guarded.
$hasGuard = $raw -match "require\.main\s*===\s*module"
$hasListen = $raw -match "(?m)^\s*app\.listen\s*\(" -or $raw -match "(?m)^\s*server\.listen\s*\("

if(-not $hasListen){
  Warn "No obvious top-level app.listen/server.listen found. We'll still enforce module.exports = { app }."
} else {
  if($hasGuard){
    Ok "require.main guard already present. We'll just ensure module.exports = { app }."
  } else {
    Info "Wrapping top-level listen call(s) with require.main guard..."

    # Wrap the FIRST occurrence of a listen block in a minimal safe way.
    # We'll target the common pattern: app.listen(...); or const server = app.listen(...);
    # and wrap ONLY that statement line (or block if it spans lines until ');').
    $pattern = "(?ms)^(?<indent>\s*)(?<stmt>(?:const\s+server\s*=\s*)?(?:app|server)\.listen\s*\(.*?\);\s*)"
    if([regex]::IsMatch($raw, $pattern, "Multiline")){
      $raw = [regex]::Replace($raw, $pattern, {
        param($m)
        $indent = $m.Groups["indent"].Value
        $stmt   = $m.Groups["stmt"].Value
        return $indent + "if (require.main === module) {" + "`n" +
               $indent + "  " + ($stmt -replace "`n", "`n$indent  ") +
               $indent + "}" + "`n"
      }, 1, "Multiline")
      Ok "Wrapped listen() with require.main guard."
    } else {
      Warn "Could not pattern-match a clean listen() statement to wrap. No wrapping applied."
    }
  }
}

# Ensure module.exports = { app } at end of file
if($raw -notmatch "(?m)^\s*module\.exports\s*=\s*\{\s*app\s*\}\s*;\s*$"){
  $raw = $raw.TrimEnd() + "`n`nmodule.exports = { app };`n"
  Ok "Added: module.exports = { app };"
} else {
  Ok "module.exports = { app } already present."
}

# --- Write back ---
Set-Content -Path $ServerFile -Value $raw -Encoding UTF8
Ok "Wrote patched server.cjs"

# --- Sanity: node syntax check ---
Push-Location $BackendDir
try {
  Info "Sanity: node --check src/server.cjs"
  & node --check "src/server.cjs"
  if($LASTEXITCODE -ne 0){ Fail "node --check failed (exit=$LASTEXITCODE)" }
  Ok "node --check OK"

  # --- Sanity: require() should NOT start listening ---
  Info "Sanity: require('./src/server.cjs') must not bind ports"
  $out = & node -e "require('./src/server.cjs'); console.log('OK_REQUIRE');" 2>&1
  if($LASTEXITCODE -ne 0){ Fail "require() sanity failed: $out" }
  if($out -notmatch "OK_REQUIRE"){ Fail "require() sanity did not print OK_REQUIRE. Output: $out" }
  Ok "require() sanity OK (no server started on import)."

  # --- Run backend tests ---
  Info "Running backend tests: npm test"
  cmd.exe /c "npm test"
  if($LASTEXITCODE -ne 0){ Fail "Backend npm test failed (exit=$LASTEXITCODE)" }
  Ok "Backend tests GREEN."
}
finally {
  Pop-Location
}

Ok "PHASE 3.1 IMPORT-SAFE COMPLETE - server.cjs no longer listens on require()."
Info ("Returned to: " + (Get-Location).Path)