# RUN_BACKEND_SANITY.ps1
# Must-pass backend checks for MindLab
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) {
  Write-Host "FAIL: $msg" -ForegroundColor Red
  exit 1
}
function Ok([string]$msg) { Write-Host "OK: $msg" -ForegroundColor Green }

$base = "http://localhost:8085"

try {
  $h = Invoke-WebRequest -UseBasicParsing "$base/health"
  if ($h.StatusCode -ne 200) { Fail "/health StatusCode=$($h.StatusCode) expected 200" }
  Ok "/health -> 200"

  $p = Invoke-WebRequest -UseBasicParsing "$base/puzzles"
  if ($p.StatusCode -ne 200) { Fail "/puzzles StatusCode=$($p.StatusCode) expected 200" }
  Ok "/puzzles -> 200"

  Ok "Backend sanity PASSED on $base"
  exit 0
}
catch {
  Fail $_.Exception.Message
}
