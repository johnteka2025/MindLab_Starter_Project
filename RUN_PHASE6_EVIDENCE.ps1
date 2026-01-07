param(
  [string]$Root = "C:\Projects\MindLab_Starter_Project"
)

if(!(Test-Path $Root)){ throw "STOP: Missing project root: $Root" }
Set-Location $Root

# Guard: require Phase 6 COMPLETE marker
$freeze6 = Get-ChildItem $Root -File -Filter "__FREEZE_PHASE6_COMPLETE_*.txt" |
  Sort-Object LastWriteTime -Descending | Select-Object -First 1
if(!$freeze6){ throw "STOP: Missing Phase 6 COMPLETE marker under: $Root" }

# Evidence folder
$stamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = Join-Path $env:TEMP "MindLab_Phase6_Evidence_$stamp"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
"OK: Evidence -> $logDir"

# Full-stack sanity
$sanity = Join-Path $Root "RUN_FULLSTACK_SANITY.ps1"
if(!(Test-Path $sanity)){ throw "STOP: Missing sanity script: $sanity" }
powershell -NoProfile -ExecutionPolicy Bypass -File $sanity *> (Join-Path $logDir "sanity.txt")
if($LASTEXITCODE -ne 0){ throw "STOP: RUN_FULLSTACK_SANITY failed (exit $LASTEXITCODE). See: $logDir\sanity.txt" }
"OK: Sanity PASS"

# Backend coverage (use cmd /c to avoid PowerShell parsing/alias issues)
$backend = Join-Path $Root "backend"
if(!(Test-Path $backend)){ throw "STOP: Missing backend folder: $backend" }
Push-Location $backend
try{
  cmd /c "npm test -- --coverage > ""$logDir\backend_coverage.txt"" 2>&1"
  if($LASTEXITCODE -ne 0){ throw "STOP: Backend coverage failed (exit $LASTEXITCODE). See: $logDir\backend_coverage.txt" }
  "OK: Backend coverage saved"
} finally { Pop-Location }

# Frontend coverage
$frontend = Join-Path $Root "frontend"
if(!(Test-Path $frontend)){ throw "STOP: Missing frontend folder: $frontend" }
Push-Location $frontend
try{
  cmd /c "npm test -- --run --coverage > ""$logDir\frontend_coverage.txt"" 2>&1"
  if($LASTEXITCODE -ne 0){ throw "STOP: Frontend coverage failed (exit $LASTEXITCODE). See: $logDir\frontend_coverage.txt" }
  "OK: Frontend coverage saved"

  # Playwright suites (stdout captured)
  cmd /c "npm run mindlab:daily-ui > ""$logDir\pw_daily-ui.txt"" 2>&1"
  if($LASTEXITCODE -ne 0){ throw "STOP: Playwright daily-ui failed (exit $LASTEXITCODE). See: $logDir\pw_daily-ui.txt" }

  cmd /c "npm run mindlab-progress-ui > ""$logDir\pw_progress-ui.txt"" 2>&1"
  if($LASTEXITCODE -ne 0){ throw "STOP: Playwright progress-ui failed (exit $LASTEXITCODE). See: $logDir\pw_progress-ui.txt" }

  cmd /c "npm run mindlab:daily-ui-optional > ""$logDir\pw_daily-ui-optional.txt"" 2>&1"
  if($LASTEXITCODE -ne 0){ throw "STOP: Playwright daily-ui-optional failed (exit $LASTEXITCODE). See: $logDir\pw_daily-ui-optional.txt" }

  "OK: Playwright logs saved"
} finally { Pop-Location }

# Invariant: INVALID difficulty must reject (400 expected)
$invOut = Join-Path $logDir "invariant_invalid_difficulty.txt"
try{
  Invoke-WebRequest "http://localhost:8085/puzzles?difficulty=INVALID" -UseBasicParsing | Out-Null
  "STOP: Expected 400 but request succeeded." | Out-File -Encoding utf8 $invOut -Append
  throw "STOP: Invariant failed (INVALID difficulty accepted)."
} catch {
  if($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 400){
    "OK: INVALID difficulty rejected (expected 400)." | Out-File -Encoding utf8 $invOut -Append
  } else {
    ("STOP: Unexpected error: " + $_.Exception.Message) | Out-File -Encoding utf8 $invOut -Append
    throw
  }
}
"OK: Invariant PASS"

# Coverage artifacts existence check (frontend HTML/json)
$covJson = Join-Path $Root "frontend\coverage\coverage-final.json"
$covHtml = Join-Path $Root "frontend\coverage\index.html"
if(!(Test-Path $covJson)){ throw "STOP: Missing $covJson" }
if(!(Test-Path $covHtml)){ throw "STOP: Missing $covHtml" }
"OK: Coverage artifacts exist"

# Create Phase 7 freeze marker (evidence verified)
$freeze7 = Join-Path $Root ("__FREEZE_PHASE7_EVIDENCE_VERIFIED_{0}_README.txt" -f $stamp)
@"
MINDLAB PHASE 7 EVIDENCE VERIFIED
Sanity: PASS
Backend coverage: PASS (saved in evidence folder)
Frontend coverage: PASS (saved in evidence folder)
Playwright suites: PASS (logs saved)
Invariant probe: PASS
Evidence folder: $logDir
Timestamp: $stamp
"@ | Set-Content -Encoding UTF8 $freeze7

"OK: Created Phase7 marker -> $freeze7"

