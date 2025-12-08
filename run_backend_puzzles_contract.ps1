# run_backend_puzzles_contract.ps1
# Compare backend /puzzles response with puzzles.json structure (id + question mapping, string-normalized IDs)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$backendBaseUrl = "http://localhost:8085"
$puzzlesPath    = "C:\Projects\MindLab_Starter_Project\backend\data\puzzles.json"

Write-Host "== Backend /puzzles contract test =="

if (-not (Test-Path $puzzlesPath)) {
    Write-Host "ERROR: puzzles.json not found at: $puzzlesPath" -ForegroundColor Red
    exit 1
}

# --- Load puzzles.json ---

try {
    $fileJson = Get-Content $puzzlesPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: puzzles.json is not valid JSON. Run validate_puzzles_json.ps1 first." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

if (-not ($fileJson -is [System.Collections.IEnumerable])) {
    Write-Host "ERROR: puzzles.json root should be an array." -ForegroundColor Red
    exit 1
}

$fileCount = ($fileJson | Measure-Object).Count
Write-Host "[INFO] puzzles.json contains $fileCount puzzle(s)."

# Build a lookup table by id from puzzles.json
# Normalize keys to strings so "1" and 1 both match.
$fileById = @{}
foreach ($p in $fileJson) {
    if ($p.id -ne $null -and $p.id -ne "") {
        $key = [string]$p.id
        $fileById[$key] = $p
    }
}

# --- Call backend /puzzles ---

$url = "$backendBaseUrl/puzzles"
Write-Host "[INFO] Calling backend: $url"

try {
    $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
}
catch {
    Write-Host "ERROR: Failed to call /puzzles endpoint." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

if ($resp.StatusCode -lt 200 -or $resp.StatusCode -ge 300) {
    Write-Host "ERROR: /puzzles returned HTTP $($resp.StatusCode)." -ForegroundColor Red
    exit 1
}

try {
    $apiJson = $resp.Content | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: /puzzles did not return valid JSON." -ForegroundColor Red
    exit 1
}

if (-not ($apiJson -is [System.Collections.IEnumerable])) {
    Write-Host "ERROR: /puzzles JSON root should be an array." -ForegroundColor Red
    exit 1
}

$apiCount = ($apiJson | Measure-Object).Count
Write-Host "[INFO] /puzzles returned $apiCount puzzle(s)."

if ($apiCount -eq 0) {
    Write-Host "ERROR: /puzzles returned an empty list." -ForegroundColor Red
    exit 1
}

# --- Contract checks for each backend puzzle ---
# Required from backend: id, question
# ID mapping to puzzles.json gives WARNs only if not found.

$requiredFields = @("id", "question")
$index    = 0
$warnings = 0

foreach ($p in $apiJson) {
    $index++

    foreach ($field in $requiredFields) {
        $hasProp = $p.PSObject.Properties.Match($field).Count -gt 0

        if (-not $hasProp) {
            Write-Host "ERROR: Backend puzzle #$index is missing required property '$field'." -ForegroundColor Red
            exit 1
        }

        $value = $p.$field
        if (-not $value) {
            Write-Host "ERROR: Backend puzzle #$index has empty value for required property '$field'." -ForegroundColor Red
            exit 1
        }
    }

    # Normalize backend id to string before lookup
    $id = [string]$p.id

    if (-not $fileById.ContainsKey($id)) {
        Write-Host "WARN: Backend puzzle id '$id' does not exist in puzzles.json (id scheme differs)." -ForegroundColor Yellow
        $warnings++
        continue
    }

    # Optional: warn if question text differs
    $filePuzzle = $fileById[$id]
    if ($filePuzzle.question -and $filePuzzle.question -ne $p.question) {
        Write-Host "WARN: Question text mismatch for id '$id' between backend and puzzles.json." -ForegroundColor Yellow
        $warnings++
    }
}

Write-Host ""
Write-Host "Backend /puzzles contract test PASSED." -ForegroundColor Green
if ($warnings -gt 0) {
    Write-Host "Note: $warnings warning(s) reported about ID/question mismatches." -ForegroundColor Yellow
}
exit 0
