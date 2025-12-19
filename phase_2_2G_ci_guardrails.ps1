# phase_2_2G_ci_guardrails.ps1
$ErrorActionPreference="Stop"
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }

$ProjectRoot="C:\Projects\MindLab_Starter_Project"
$BackendTest="C:\Projects\MindLab_Starter_Project\backend\tests\contract\progress_api.contract.test.js"

if(!(Test-Path $BackendTest)){ Fail "Missing: $BackendTest" }

$c = Get-Content -Raw $BackendTest
if($c -notmatch "spawn\("){ Fail "Guardrail: contract test does not appear to self-host (spawn not found)." }

Ok "Guardrail passed: contract test appears self-hosted."
Info "Done."
