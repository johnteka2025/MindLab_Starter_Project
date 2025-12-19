Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function WriteUtf8NoBom([string]$Path, [string]$Content) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

Say "=== Phase 2.2A: Frontend test guardrails + sanity run (NO backups executed) ==="

$startDir = Get-Location
try {
  # Project root = folder where this script lives
  $projectRoot = Split-Path -Parent $PSCommandPath
  $frontendDir  = Join-Path $projectRoot "frontend"
  if (-not (Test-Path $frontendDir)) { Fail "frontend folder not found at: $frontendDir" }

  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $backupDir = Join-Path $frontendDir "backups\manual_edits\PHASE_2_2A_$stamp"
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

  Say "[INFO] ProjectRoot: $projectRoot"
  Say "[INFO] FrontendDir: $frontendDir"
  Say "[INFO] BackupDir:   $backupDir"

  # 1) Backup package.json
  $pkgPath = Join-Path $frontendDir "package.json"
  if (-not (Test-Path $pkgPath)) { Fail "Missing: $pkgPath" }
  $pkgBackup = Join-Path $backupDir "package.json.BEFORE"
  Copy-Item $pkgPath $pkgBackup -Force
  Ok "Backed up package.json -> $pkgBackup"

  # 2) Create/overwrite Playwright config to IGNORE backups (prevents running backup tests)
  #    This is the key fix for: “Why are we running backup files?”
  $pwConfig = Join-Path $frontendDir "playwright.config.ts"
  $pwBackup = Join-Path $backupDir "playwright.config.ts.BEFORE"
  if (Test-Path $pwConfig) {
    Copy-Item $pwConfig $pwBackup -Force
    Ok "Backed up playwright.config.ts -> $pwBackup"
  }

  $pwContent = @'
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests_e2e",
  testMatch: ["**/*.spec.ts", "**/*.spec.js"],
  testIgnore: [
    "**/backups/**",
    "**/node_modules/**",
    "**/.git/**"
  ],
  use: {
    baseURL: process.env.APP_URL || "http://localhost:5177/app",
  },
});
'@
  WriteUtf8NoBom $pwConfig $pwContent
  Ok "Wrote Playwright config with backups ignored: $pwConfig"

  # 3) Sanity: package.json parses (run via cmd.exe to avoid PS quoting problems)
  Say "=== Sanity: frontend/package.json parses as JSON ==="
  Push-Location $frontendDir
  try {
    cmd.exe /c "node -e ""JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('OK: package.json parses')"""
  } finally {
    Pop-Location
  }

  # 4) Install if needed
  $nodeModules = Join-Path $frontendDir "node_modules"
  if (-not (Test-Path $nodeModules)) {
    Say "=== Installing frontend deps (npm install) ==="
    Push-Location $frontendDir
    try {
      cmd.exe /c "npm install"
      if ($LASTEXITCODE -ne 0) { Fail "npm install failed (exit $LASTEXITCODE)" }
      Ok "npm install finished green."
    } finally {
      Pop-Location
    }
  } else {
    Ok "node_modules exists (skipping npm install)."
  }

  # 5) Run frontend tests (whatever your frontend defines). Playwright config now ignores backups.
  Say "=== Running frontend tests (npm test) ==="
  Push-Location $frontendDir
  try {
    cmd.exe /c "npm test"
    if ($LASTEXITCODE -ne 0) { Fail "frontend npm test failed (exit $LASTEXITCODE)" }
    Ok "frontend npm test finished green."
  } finally {
    Pop-Location
  }

  Ok "PHASE 2.2A COMPLETE - frontend sanity/tests executed."
  Say "[INFO] Backups in: $backupDir"
}
finally {
  Set-Location $startDir
  Say "[INFO] Returned to: $((Get-Location).Path)"
  Read-Host "Press ENTER to continue"
}
