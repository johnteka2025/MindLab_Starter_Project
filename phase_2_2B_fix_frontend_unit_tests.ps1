Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Gray }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ throw "[FAIL] $m" }

function WriteUtf8NoBom([string]$path, [string]$content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

$startDir = Get-Location
try {
  Say "=== Phase 2.2B: Fix frontend unit tests (Vitest must ignore e2e/backups/node_modules) ==="

  $projectRoot = "C:\Projects\MindLab_Starter_Project"
  $frontendDir = Join-Path $projectRoot "frontend"
  if (-not (Test-Path $frontendDir)) { Fail "Missing frontend dir: $frontendDir" }

  $backupRoot = Join-Path $frontendDir ("backups\manual_edits\PHASE_2_2B_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
  New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

  Info "FrontendDir: $frontendDir"
  Info "Backups in:  $backupRoot"

  # --- Backup key files (safe + reversible) ---
  $pkgPath = Join-Path $frontendDir "package.json"
  if (Test-Path $pkgPath) {
    Copy-Item $pkgPath (Join-Path $backupRoot "package.json.BEFORE") -Force
    Ok "Backed up package.json"
  } else {
    Warn "package.json not found (unexpected): $pkgPath"
  }

  $vitestConfigPath = Join-Path $frontendDir "vitest.config.ts"
  if (Test-Path $vitestConfigPath) {
    Copy-Item $vitestConfigPath (Join-Path $backupRoot "vitest.config.ts.BEFORE") -Force
    Ok "Backed up vitest.config.ts"
  } else {
    Warn "vitest.config.ts not found - will create one."
  }

  # --- Write known-good vitest config ---
  # Key idea:
  #  - include ONLY src unit tests
  #  - exclude tests/e2e, backups, node_modules
  $vitestConfig = @"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Only run unit tests from src/
    include: ['src/**/*.{test,spec}.{ts,tsx,js,jsx}'],

    // Hard exclusions (prevents Vitest from touching Playwright e2e specs & backups)
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/coverage/**',
      '**/backups/**',
      'tests/e2e/**',
      '**/*.e2e.*',
      '**/*.pw.*'
    ]
  }
});
"@

  WriteUtf8NoBom $vitestConfigPath $vitestConfig
  Ok "Wrote clean vitest.config.ts (unit tests only)"

  # --- Sanity: package.json parses ---
  Push-Location $frontendDir
  cmd.exe /c "node -e ""JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('OK: package.json parses')"""
  Pop-Location
  Ok "Sanity: package.json parses"

  # --- Install (if needed) ---
  if (-not (Test-Path (Join-Path $frontendDir "node_modules"))) {
    Say "Installing frontend deps (npm install)..."
    Push-Location $frontendDir
    cmd.exe /c "npm install"
    if ($LASTEXITCODE -ne 0) { Fail "npm install failed (exit $LASTEXITCODE)" }
    Pop-Location
    Ok "npm install finished"
  } else {
    Info "node_modules exists (skipping npm install)"
  }

  # --- Run unit tests ---
  Say "Running frontend unit tests (npm test)..."
  Push-Location $frontendDir
  cmd.exe /c "npm test"
  $exit = $LASTEXITCODE
  Pop-Location

  if ($exit -ne 0) {
    Fail "frontend npm test failed (exit $exit). If this still shows e2e specs, we will tighten includes further."
  }

  Ok "Phase 2.2B complete: frontend unit tests GREEN"
  Info "Backups in: $backupRoot"
}
finally {
  Set-Location $startDir
  Info ("Returned to: " + (Get-Location).Path)
  Read-Host "Press ENTER to continue"
}