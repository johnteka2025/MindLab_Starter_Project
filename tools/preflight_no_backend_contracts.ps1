Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Stop-Fail { param([string]$Message) Write-Host $Message -ForegroundColor Red; $global:LASTEXITCODE=1 }
function Stop-Ok   { param([string]$Message) Write-Host $Message -ForegroundColor Green; $global:LASTEXITCODE=0 }

try {
  if (-not (Test-Path ".git")) { Stop-Fail "STOP: Not at repo root (.git missing)."; exit $global:LASTEXITCODE }

  $dirty = @(git status --porcelain)
  if ($dirty.Count -gt 0) { $dirty | Out-Host; Stop-Fail "STOP: Repo must be clean before No-Backend contract gate."; exit $global:LASTEXITCODE }
  Stop-Ok "OK: Repo clean."

  $runner = "tools\run_contract_clean.ps1"
  $backendPkg = "backend\package.json"
  if (-not (Test-Path $runner)) { Stop-Fail "STOP: Missing runner: tools\run_contract_clean.ps1"; exit $global:LASTEXITCODE }
  if (-not (Test-Path $backendPkg)) { Stop-Fail "STOP: Missing backend package.json: backend\package.json"; exit $global:LASTEXITCODE }
  Stop-Ok "OK: Required files exist."

  $t=$null; $e=$null
  [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $runner).Path,[ref]$t,[ref]$e) | Out-Null
  if ($e -and $e.Count -gt 0) { $e | Format-Table Message,Extent -AutoSize | Out-Host; Stop-Fail "STOP: Runner parse errors."; exit $global:LASTEXITCODE }
  Stop-Ok "OK: Runner parses."

  $pkg = Get-Content -Raw -Encoding UTF8 $backendPkg | ConvertFrom-Json
  if (-not $pkg.scripts -or -not $pkg.scripts.'test:contract') { Stop-Fail "STOP: backend/package.json missing scripts.test:contract"; exit $global:LASTEXITCODE }
  Stop-Ok "OK: backend/package.json has scripts.test:contract"

  if (-not (Select-String -Path $runner -Pattern "test:contract" -Quiet)) { Stop-Fail "STOP: Runner does not reference 'test:contract'."; exit $global:LASTEXITCODE }
  if (Select-String -Path $runner -Pattern "\bnpm\s+test\b" -Quiet) { Stop-Fail "STOP: Runner still uses 'npm test'."; exit $global:LASTEXITCODE }
  Stop-Ok "OK: Runner uses test:contract and not npm test."

  Write-Host "OK: No-backend preflight passed." -ForegroundColor Green
  $global:LASTEXITCODE=0
  exit $global:LASTEXITCODE
}
catch {
  Write-Host ("STOP: Preflight crashed: {0}" -f $_.Exception.Message) -ForegroundColor Red
  $global:LASTEXITCODE=1
  exit $global:LASTEXITCODE
}
