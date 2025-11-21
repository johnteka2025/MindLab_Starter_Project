[CmdletBinding()]
param([switch]$RunFrontend)
$ErrorActionPreference = "Stop"; Set-StrictMode -Version Latest
$ROOT = "C:\Projects\MindLab_Starter_Project"; Set-Location $ROOT
function Step($t,[scriptblock]$b){ Write-Host "`n==== $t ====" -ForegroundColor Cyan; & $b; if($LASTEXITCODE -ne 0){ Write-Host "[FAIL] $t" -ForegroundColor Red; exit $LASTEXITCODE } }
Step "Reset"            { .\ops\0_reset.ps1 }
Step "Sanity (pre)"     { .\ops\1_sanity.ps1 }
Step "Start Backend"    { .\ops\2_start-backend.ps1 }
if ($RunFrontend) { Step "Start Frontend" { .\ops\3_start-frontend.ps1 } }
Step "Core Tests"       { .\ops\4_test-core.ps1 }
Step "Contract Tests"   { .\ops\5_test-contract.ps1 }
Step "Load Tests (k6)"  { .\ops\6_test-k6.ps1 }
Write-Host "`n[ALL STEPS PASSED]" -ForegroundColor Green
