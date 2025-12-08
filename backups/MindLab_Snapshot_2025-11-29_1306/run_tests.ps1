$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# Ensure servers are up
.\run_all.ps1 | Out-Host

Write-Host "`n=== Running tests ==="
# Use Node's built-in test runner
pushd $PSScriptRoot
node --test .\tests\*.cjs
$code = $LASTEXITCODE
popd

Write-Host "`n=== Test exit code: $code ==="
if ($code -ne 0) {
  Write-Warning "Some tests failed. Showing logs..."
  .\logs.ps1
  if (Test-Path .\backend\logs\backend.log) {
    Write-Host "`n--- backend.log (tail) ---"
    Get-Content .\backend\logs\backend.log -Tail 100
  }
  exit $code
}
Write-Host "All tests passed."
