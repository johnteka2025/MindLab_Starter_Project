# phase_2_1D_fix_puzzles_json_CLEAN_v2.ps1
# Fix backend\src\puzzles.json to valid JSON + proof parse + run backend tests (cmd.exe /c npm test)
# SAFE: creates backups + UTF-8 (no BOM) + returns to start dir

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Say($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[ERROR] $m" -ForegroundColor Red; throw $m }

$startDir = Get-Location

try {
    # --- Resolve project root safely ---
    $projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (-not $projectRoot) { $projectRoot = (Get-Location).Path }
    Set-Location $projectRoot

    Say "=== Phase 2.1D (CLEAN v2): Fix puzzles.json + proof + npm test ==="
    Write-Host "[INFO] ProjectRoot: $projectRoot" -ForegroundColor Gray

    $backendDir  = Join-Path $projectRoot "backend"
    $puzzlesPath = Join-Path $backendDir  "src\puzzles.json"

    if (-not (Test-Path $backendDir))  { Fail "Missing backend folder: $backendDir" }
    if (-not (Test-Path $puzzlesPath)) { Fail "Missing puzzles file: $puzzlesPath" }

    Write-Host "[INFO] BackendDir : $backendDir" -ForegroundColor Gray
    Write-Host "[INFO] Puzzles    : $puzzlesPath" -ForegroundColor Gray

    # --- Backup dir ---
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path $backendDir ("backups\manual_edits\PHASE_2_1D_CLEAN_v2_{0}" -f $stamp)
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

    $backupPuzzles = Join-Path $backupDir "puzzles.json.BEFORE"
    Copy-Item -Force $puzzlesPath $backupPuzzles
    Ok "Backup created: $backupPuzzles"

    # --- Write known-good valid JSON array (edit later if you want more puzzles) ---
    $puzzlesObj = @(
        @{ id = 1; question = "What is 2 + 2?"; options = @("3","4","5") },
        @{ id = 2; question = "What is the color of the sky?"; options = @("Blue","Green","Red") },
        @{ id = 3; question = "Which shape has 3 sides?"; options = @("Triangle","Square","Circle") }
    )

    $json = $puzzlesObj | ConvertTo-Json -Depth 10

    # Write UTF-8 NO-BOM to avoid hidden chars
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($puzzlesPath, $json, $utf8NoBom)
    Ok "Wrote valid JSON array to: $puzzlesPath"

    # --- Proof: Node JSON.parse using temp JS file (NO node -e quoting issues) ---
    $proofJs = Join-Path $backupDir "proof_parse_puzzles.js"
    $proofContent = @"
const fs = require("fs");
const p = process.argv[2];
const s = fs.readFileSync(p, "utf8");
JSON.parse(s);
console.log("OK: puzzles.json parses as JSON");
"@
    [System.IO.File]::WriteAllText($proofJs, $proofContent, $utf8NoBom)

    Say "--- Proof: node proof_parse_puzzles.js puzzles.json ---"
    & node $proofJs $puzzlesPath
    if ($LASTEXITCODE -ne 0) { Fail "Node JSON.parse proof FAILED (exit $LASTEXITCODE)." }
    Ok "Node parse proof passed."

    # --- Run backend tests via CMD to avoid PowerShell npm shim issues ---
    Say "--- Running backend tests (cmd.exe /c npm test) ---"
    Push-Location $backendDir
    try {
        & cmd.exe /c "npm test"
        $exit = $LASTEXITCODE
        if ($exit -ne 0) { Fail "npm test FAILED with exit code $exit" }
        Ok "npm test finished green."
    }
    finally {
        Pop-Location
    }

    Ok "Phase 2.1D CLEAN v2 complete."
    Write-Host "[INFO] Backups in: $backupDir" -ForegroundColor Gray
}
catch {
    Write-Host ""
    Write-Host "=== FAILURE DETAILS ===" -ForegroundColor Red
    Write-Host ($_.Exception.Message) -ForegroundColor Red
    Write-Host ""
    throw
}
finally {
    Set-Location $startDir
    Write-Host "[INFO] Returned to: $((Get-Location).Path)" -ForegroundColor Gray
    Read-Host "Press ENTER to continue"
}
