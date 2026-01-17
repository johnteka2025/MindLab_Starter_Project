Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Always end at repo root
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $repoRoot
try {
  $file = ".\backend\src\daily-challenge\dailyChallengeRoutes.ts"
  if (-not (Test-Path -LiteralPath $file)) { throw "STOP: missing target file: $file" }

  $backup = Join-Path $env:TEMP "dailyChallengeRoutes.ts.preAnswerValidation.backup"
  Copy-Item -LiteralPath $file -Destination $backup -Force

  Write-Host "EDIT THIS FILE NOW (save when done): $file"
  Write-Host "Backup: $backup"

  # Open editor (choose one). Comment out the one you don't want.
  notepad $file
  # code $file

  Write-Host "Running backend tests..."
  npm --prefix ".\backend" test
}
finally {
  Pop-Location
  Set-Location $repoRoot
}
