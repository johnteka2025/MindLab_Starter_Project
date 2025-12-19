# phase_2_2D_add_prod_playwright_runner.ps1
# Adds PROD-only Playwright runner (separate config + npm script) without breaking LOCAL.
# Safe: backups + sanity + returns to start dir

$ErrorActionPreference = 'Stop'

function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

function WriteUtf8NoBom([string]$Path, [string]$Content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function AssertPath([string]$p){
  if (-not (Test-Path -LiteralPath $p)) { Fail "Missing path: $p" }
}

function EnsureScriptsObject([object]$pkg){
  if (-not $pkg.PSObject.Properties.Match('scripts')) {
    $pkg | Add-Member -MemberType NoteProperty -Name scripts -Value ([pscustomobject]@{}) -Force
  }
  if ($null -eq $pkg.scripts) {
    $pkg.scripts = [pscustomobject]@{}
  }
}

function SetNpmScript([object]$scripts, [string]$name, [string]$cmd){
  # Works for BOTH Hashtable and PSCustomObject, including keys like "test:e2e:prod"
  if ($scripts -is [hashtable]) {
    $scripts[$name] = $cmd
    return
  }

  $prop = $scripts.PSObject.Properties[$name]
  if ($null -eq $prop) {
    $scripts | Add-Member -MemberType NoteProperty -Name $name -Value $cmd -Force
  } else {
    $prop.Value = $cmd
  }
}

$startDir = Get-Location

try {
  $root = 'C:\Projects\MindLab_Starter_Project'
  $frontendDir = Join-Path $root 'frontend'

  AssertPath $root
  AssertPath $frontendDir
  AssertPath (Join-Path $frontendDir 'package.json')
  AssertPath (Join-Path $frontendDir 'playwright.config.ts')

  $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
  $backupRoot = Join-Path $frontendDir ("backups\manual_edits\PHASE_2_2D_{0}" -f $ts)
  New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

  Info ("ProjectRoot: {0}" -f $root)
  Info ("FrontendDir: {0}" -f $frontendDir)
  Info ("Backups in:  {0}" -f $backupRoot)

  # Backups (reversible)
  Copy-Item -LiteralPath (Join-Path $frontendDir 'package.json') `
    -Destination (Join-Path $backupRoot 'package.json.BEFORE') -Force
  Copy-Item -LiteralPath (Join-Path $frontendDir 'playwright.config.ts') `
    -Destination (Join-Path $backupRoot 'playwright.config.ts.BEFORE') -Force
  Ok 'Backed up package.json + playwright.config.ts'

  # Write PROD-only Playwright config (runs ONLY *-prod.spec.*)
  $prodCfgPath = Join-Path $frontendDir 'playwright.prod.config.ts'

  $prodCfg = @'
import { defineConfig } from "@playwright/test";

// PROD-only config:
// - Runs ONLY *-prod.spec.*
// - Ignores backups
const HOME_URL = process.env.MINDLAB_HOME_URL ?? "https://mindlab-swpk.onrender.com/app";

export default defineConfig({
  testDir: "./tests/e2e",
  testMatch: ["**/*-prod.spec.*"],
  testIgnore: ["**/backups/**"],
  timeout: 30_000,
  retries: 0,
  use: {
    baseURL: HOME_URL,
    trace: "on-first-retry",
  },
  reporter: [["html", { open: "never" }]],
});
'@

  WriteUtf8NoBom $prodCfgPath $prodCfg
  Ok 'Wrote playwright.prod.config.ts (PROD-only)'

  # Update package.json scripts safely
  Push-Location $frontendDir

  $pkgPath = Join-Path $frontendDir 'package.json'
  $pkg = Get-Content -Raw -LiteralPath $pkgPath | ConvertFrom-Json
  EnsureScriptsObject $pkg
  $scripts = $pkg.scripts

  # Keep existing scripts if already present; add missing ones
  if ($null -eq $scripts.PSObject.Properties['test:e2e'] -and -not ($scripts -is [hashtable] -and $scripts.ContainsKey('test:e2e'))) {
    SetNpmScript $scripts 'test:e2e' 'playwright test'
  }
  if ($null -eq $scripts.PSObject.Properties['test:e2e:ui'] -and -not ($scripts -is [hashtable] -and $scripts.ContainsKey('test:e2e:ui'))) {
    SetNpmScript $scripts 'test:e2e:ui' 'playwright test --ui'
  }
  if ($null -eq $scripts.PSObject.Properties['test:e2e:headed'] -and -not ($scripts -is [hashtable] -and $scripts.ContainsKey('test:e2e:headed'))) {
    SetNpmScript $scripts 'test:e2e:headed' 'playwright test --headed'
  }
  if ($null -eq $scripts.PSObject.Properties['test:e2e:report'] -and -not ($scripts -is [hashtable] -and $scripts.ContainsKey('test:e2e:report'))) {
    SetNpmScript $scripts 'test:e2e:report' 'playwright show-report'
  }

  # NEW: prod-only runner (always set/update)
  SetNpmScript $scripts 'test:e2e:prod' 'playwright test --config=playwright.prod.config.ts'

  $json = $pkg | ConvertTo-Json -Depth 100
  WriteUtf8NoBom $pkgPath $json
  Ok 'Updated package.json (added/updated test:e2e:prod)'

  # Sanity: package.json parses
  cmd.exe /c "node -e ""JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('OK: package.json parses')"""
  if ($LASTEXITCODE -ne 0) { Fail 'package.json parse sanity failed' }

  Pop-Location

  AssertPath $prodCfgPath
  Ok 'PHASE 2.2D COMPLETE — PROD runner added (LOCAL runner unchanged)'
  Info ("Backups: {0}" -f $backupRoot)
  Info ("Next LOCAL: cd `"{0}`" ; npm run test:e2e" -f $frontendDir)
  Info ("Next PROD : cd `"{0}`" ; npm run test:e2e:prod" -f $frontendDir)
}
finally {
  Set-Location $startDir
  Info ("Returned to: {0}" -f (Get-Location).Path)
}
