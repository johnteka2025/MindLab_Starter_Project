# phase_2_2C_setup_playwright_e2e.ps1
# Purpose: Ensure Playwright E2E is run ONLY by Playwright (not Vitest), and add safe npm scripts.
# Safety: backs up files, parse-check friendly, reversible.
# Run from: C:\Projects\MindLab_Starter_Project

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function WriteUtf8NoBom([string]$path, [string]$content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function Backup-File([string]$src, [string]$dstDir) {
  if (Test-Path $src) {
    $name = [System.IO.Path]::GetFileName($src)
    $dst = Join-Path $dstDir ($name + ".BEFORE")
    Copy-Item $src $dst -Force
    Ok "Backed up $name -> $dst"
  } else {
    Warn "Not found (skip backup): $src"
  }
}

$startDir = Get-Location
try {
  $projectRoot = "C:\Projects\MindLab_Starter_Project"
  if (-not (Test-Path $projectRoot)) { Fail "ProjectRoot missing: $projectRoot" }

  $frontendDir = Join-Path $projectRoot "frontend"
  if (-not (Test-Path $frontendDir)) { Fail "FrontendDir missing: $frontendDir" }

  $stamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
  $backupDir = Join-Path $frontendDir ("backups\manual_edits\PHASE_2_2C_{0}" -f $stamp)
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

  Say "=== Phase 2.2C: Setup Playwright E2E correctly (Vitest unit-only) ==="
  Write-Host "[INFO] ProjectRoot: $projectRoot"
  Write-Host "[INFO] FrontendDir: $frontendDir"
  Write-Host "[INFO] Backups in:  $backupDir"

  $pkgPath = Join-Path $frontendDir "package.json"
  $pwConfigPath = Join-Path $frontendDir "playwright.config.ts"
  $vitestConfigPath = Join-Path $frontendDir "vitest.config.ts"

  # --- Backups ---
  Backup-File $pkgPath $backupDir
  Backup-File $pwConfigPath $backupDir
  Backup-File $vitestConfigPath $backupDir

  # --- Load package.json ---
  if (-not (Test-Path $pkgPath)) { Fail "Missing: $pkgPath" }
  $pkg = Get-Content -Raw $pkgPath | ConvertFrom-Json

  if (-not $pkg.scripts) { $pkg | Add-Member -NotePropertyName scripts -NotePropertyValue (@{}) }
  if (-not $pkg.devDependencies) { $pkg | Add-Member -NotePropertyName devDependencies -NotePropertyValue (@{}) }

  # --- Ensure Playwright dependency ---
  $hasPlaywright = $false
  if ($pkg.devDependencies.PSObject.Properties.Name -contains "@playwright/test") { $hasPlaywright = $true }

  # --- Add safe scripts (DO NOT replace existing ones) ---
  if (-not ($pkg.scripts.PSObject.Properties.Name -contains "test:e2e")) {
    $pkg.scripts | Add-Member -NotePropertyName "test:e2e" -NotePropertyValue "playwright test"
    Ok "Added npm script: test:e2e"
  } else { Ok "npm script exists: test:e2e (no change)" }

  if (-not ($pkg.scripts.PSObject.Properties.Name -contains "test:e2e:ui")) {
    $pkg.scripts | Add-Member -NotePropertyName "test:e2e:ui" -NotePropertyValue "playwright test --ui"
    Ok "Added npm script: test:e2e:ui"
  } else { Ok "npm script exists: test:e2e:ui (no change)" }

  if (-not ($pkg.scripts.PSObject.Properties.Name -contains "test:e2e:headed")) {
    $pkg.scripts | Add-Member -NotePropertyName "test:e2e:headed" -NotePropertyValue "playwright test --headed"
    Ok "Added npm script: test:e2e:headed"
  } else { Ok "npm script exists: test:e2e:headed (no change)" }

  if (-not ($pkg.scripts.PSObject.Properties.Name -contains "test:e2e:report")) {
    $pkg.scripts | Add-Member -NotePropertyName "test:e2e:report" -NotePropertyValue "playwright show-report"
    Ok "Added npm script: test:e2e:report"
  } else { Ok "npm script exists: test:e2e:report (no change)" }

  # --- Write package.json back (UTF-8 no BOM) ---
  WriteUtf8NoBom $pkgPath ($pkg | ConvertTo-Json -Depth 100)
  Ok "Updated frontend/package.json"

  # --- Ensure vitest excludes E2E/backups/node_modules (unit tests only) ---
  if (Test-Path $vitestConfigPath) {
    $v = Get-Content -Raw $vitestConfigPath

    # If it already contains tests/e2e exclusion, do nothing.
    if ($v -match "tests/e2e" -and $v -match "backups") {
      Ok "vitest.config.ts already excludes tests/e2e + backups (no change)"
    } else {
      Warn "vitest.config.ts exists but may not exclude tests/e2e/backups. We'll append a safe exclude block if missing."
      # Minimal append approach: add a comment marker and a snippet the file can use.
      # We won't try to rewrite your config structurally (avoid breaking it).
      $append = @"

//
// [PHASE_2_2C] Reminder:
// Ensure Vitest excludes Playwright E2E + backups:
// test: { exclude: ['**/tests/e2e/**','**/backups/**','**/node_modules/**'] }
//
"@
      WriteUtf8NoBom $vitestConfigPath ($v.TrimEnd() + $append)
      Ok "Appended Phase 2.2C reminder to vitest.config.ts (manual-safe, non-breaking)"
    }
  } else {
    Warn "vitest.config.ts not found (skip). Your npm test currently runs and is green, so OK."
  }

  # --- Write Playwright config (safe defaults) ---
  $pwConfig = @"
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  testMatch: ['**/*.spec.ts', '**/*.spec.tsx'],
  // Critical: do NOT run backups, and do NOT run prod specs by default
  testIgnore: ['**/backups/**', '**/*-prod.spec.*'],
  fullyParallel: true,
  timeout: 60_000,
  expect: { timeout: 10_000 },
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: process.env.MINDLAB_E2E_BASE_URL || 'http://localhost:5177',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
"@

  WriteUtf8NoBom $pwConfigPath $pwConfig
  Ok "Wrote frontend/playwright.config.ts (E2E only, ignores backups + *-prod.spec.*)"

  # --- Install Playwright if needed ---
  Push-Location $frontendDir
  try {
    if (-not $hasPlaywright) {
      Say "=== Installing @playwright/test (devDependency) ==="
      cmd.exe /c "npm install -D @playwright/test"
      if ($LASTEXITCODE -ne 0) { Fail "npm install -D @playwright/test failed" }
      Ok "@playwright/test installed"
    } else {
      Ok "@playwright/test already present (no install)"
    }

    Say "=== Installing Playwright browsers (safe) ==="
    cmd.exe /c "npx playwright install"
    if ($LASTEXITCODE -ne 0) { Fail "npx playwright install failed" }
    Ok "Playwright browsers installed"
  }
  finally {
    Pop-Location
  }

  Ok "Phase 2.2C setup complete."
  Write-Host "[INFO] Next: Start backend + frontend, then run: (cd frontend) npm run test:e2e" -ForegroundColor Cyan
  Write-Host "[INFO] Backups: $backupDir" -ForegroundColor Cyan
}
finally {
  Set-Location $startDir
  Write-Host "[INFO] Returned to: $((Get-Location).Path)" -ForegroundColor DarkGray
}
