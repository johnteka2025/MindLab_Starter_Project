Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Step([string]$name) { Write-Host ("=== STEP: {0} ===" -f $name) -ForegroundColor Cyan }
function Fail([string]$m) { Write-Host $m -ForegroundColor Red; $global:LASTEXITCODE=1; exit $global:LASTEXITCODE }
function Ok([string]$m) { Write-Host $m -ForegroundColor Green }

function CmdOut([string]$cmd) {
  # Runs through cmd.exe to avoid PowerShell npm invocation issues
  & cmd.exe /d /c $cmd 2>&1
  $global:LASTEXITCODE = $LASTEXITCODE
}

try {
  Step "Repo root + backend paths"
  $repo = (Resolve-Path ".").Path
  if (-not (Test-Path (Join-Path $repo ".git"))) { Fail "STOP: Not at repo root (.git missing)." }

  $backend = Join-Path $repo "backend"
  if (-not (Test-Path $backend)) { Fail "STOP: Missing backend folder at: $backend" }

  $pkgPath = Join-Path $backend "package.json"
  if (-not (Test-Path $pkgPath)) { Fail "STOP: Missing backend\package.json at: $pkgPath" }
  Ok "OK: Backend detected."

  Step "Environment"
  Write-Host ("PSVersion => {0}" -f $PSVersionTable.PSVersion) -ForegroundColor Yellow

  Step "Resolve npm command"
  Get-Command npm -All | Format-Table CommandType,Name,Source,Version -AutoSize | Out-Host
  & where.exe npm 2>&1 | Out-Host

  Step "Node + NPM versions (cmd.exe)"
  Push-Location $backend
  try {
    $nodeV = CmdOut "node -v"
    $nodeV | Out-Host
    if ($LASTEXITCODE -ne 0) { Fail "STOP: node -v failed via cmd.exe" }
  } catch { Fail ("STOP: node -v crashed: {0}" -f $_.Exception.Message) }

  try {
    $npmV = CmdOut "npm -v"
    $npmV | Out-Host
    if ($LASTEXITCODE -ne 0) { Fail "STOP: npm -v failed via cmd.exe" }
  } catch { Fail ("STOP: npm -v crashed: {0}" -f $_.Exception.Message) }

  Step "Parse package.json and read scripts.test:contract"
  try {
    $pkg = Get-Content -Raw -Encoding UTF8 $pkgPath | ConvertFrom-Json
  } catch {
    Fail ("STOP: Failed to parse backend/package.json as JSON: {0}" -f $_.Exception.Message)
  }

  if (-not $pkg.scripts -or -not $pkg.scripts.'test:contract') {
    Fail "STOP: backend/package.json missing scripts.test:contract"
  }
  Write-Host ("test:contract => {0}" -f $pkg.scripts.'test:contract') -ForegroundColor Yellow

  Step "Contract test files on disk"
  $contractDir = Join-Path $backend "tests\contract"
  if (-not (Test-Path $contractDir)) { Fail "STOP: Missing backend\tests\contract folder" }

  $files = Get-ChildItem $contractDir -Recurse -File | Where-Object {
    $_.Name -match '\.test\.js$' -or $_.Name -match '\.contract\.test\.js$'
  }

  if (-not $files -or $files.Count -eq 0) {
    Write-Host "WARN: No *.test.js or *.contract.test.js files found under backend\tests\contract" -ForegroundColor Yellow
  } else {
    $files | Select-Object FullName | Out-Host
  }

  Step "Jest availability (cmd.exe)"
  $jestV = CmdOut "npx jest --version"
  $jestV | Out-Host
  if ($LASTEXITCODE -ne 0) { Fail "STOP: npx jest --version failed via cmd.exe" }

  Step "Jest discovery (listTests)"
  $list = CmdOut "npx jest --listTests"
  $list | Out-Host
  if ($LASTEXITCODE -ne 0) { Fail "STOP: jest --listTests failed. Fix Jest install/config first." }

  Ok "OK: Discovery debug completed."
  $global:LASTEXITCODE = 0
  exit $global:LASTEXITCODE
}
catch {
  Write-Host ("STOP: jest_discovery_debug crashed: {0}" -f $_.Exception.Message) -ForegroundColor Red
  $global:LASTEXITCODE = 1
  exit $global:LASTEXITCODE
}
finally {
  try { Pop-Location } catch {}
}
