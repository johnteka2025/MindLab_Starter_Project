[CmdletBinding()]
param(
  [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$targets = @(
  Join-Path $Root "tools\run_contract_clean.ps1"
  Join-Path $Root "tools\preflight.ps1"
  Join-Path $Root "tools\all_tests.ps1"
)

foreach ($t in $targets) {
  if (-not (Test-Path $t)) { throw "Missing: $t" }
}

# Forbidden: a standalone pm command token on a line (start or after '&')
$pattern1 = '(^|\r?\n)\s*pm(\s|$)'
$pattern2 = '(^|\r?\n)\s*&\s*pm(\s|$)'

foreach ($t in $targets) {
  $raw = Get-Content $t -Raw
  if ($raw -match $pattern1 -or $raw -match $pattern2) {
    throw "Forbidden 'pm' command token found in: $t"
  }
}

Write-Host "OK: forbidden-token guard passed" -ForegroundColor Green
