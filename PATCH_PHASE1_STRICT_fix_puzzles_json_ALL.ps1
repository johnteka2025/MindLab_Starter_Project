# PATCH_PHASE1_STRICT_fix_puzzles_json_ALL.ps1
# Strictly fix puzzles JSON files so Node JSON.parse succeeds.
# - Finds all puzzles.json + index.json under backend\src
# - For any file that starts with "{" (not "["), wraps it into a JSON array
# - Validates using Node's JSON.parse (strict)
# - Calls backend endpoints after fix
# - Returns to project root (Golden Rule)

$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
$backend = Join-Path $root "backend"
$src = Join-Path $backend "src"
$backupDir = Join-Path $backend "backups"

Write-Host "== Phase 1 STRICT JSON fix starting =="
Write-Host "Root: $root"

if (-not (Test-Path $backend)) { throw "Missing backend folder: $backend" }
if (-not (Test-Path $src)) { throw "Missing backend src folder: $src" }

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

function Backup-File($path) {
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $name = Split-Path $path -Leaf
  $bak = Join-Path $backupDir "$name.bak_$ts"
  Copy-Item $path $bak -Force
  Write-Host "Backed up: $path -> $bak"
}

function Node-JsonParse-Ok([string]$text) {
  # Use Node for strict JSON.parse validation
  $js = @"
try {
  JSON.parse(process.argv[1]);
  process.exit(0);
} catch (e) {
  console.error(String(e && e.message ? e.message : e));
  process.exit(2);
}
"@
  $out = & node -e $js $text 2>&1
  if ($LASTEXITCODE -eq 0) { return $true }
  return $false
}

function Fix-IfNeeded($path) {
  Write-Host "`n--- Checking: $path ---"
  $raw = Get-Content -Raw -Path $path
  $trim = $raw.Trim()

  # If it's already strict-valid JSON, do nothing
  if (Node-JsonParse-Ok $trim) {
    Write-Host "OK: strict JSON.parse already accepts this file."
    return
  }

  Backup-File $path

  # If it begins with '{', it's almost certainly "array missing [ ]" => wrap it.
  if ($trim.StartsWith("{")) {
    $wrapped = "[`r`n$trim`r`n]"
    if (-not (Node-JsonParse-Ok $wrapped)) {
      throw "Wrapping with [ ] still not strict-valid for: $path`nThis file needs manual correction."
    }
    Set-Content -Path $path -Value $wrapped -Encoding UTF8
    Write-Host "FIXED: wrapped into JSON array []"
    return
  }

  # If it starts with something else, we don't guess—fail loudly.
  throw "File is not strict-valid JSON and does not start with '{' (cannot auto-fix safely): $path"
}

Write-Host "`n--- Finding candidate puzzle json files under backend\src ---"
$candidates = Get-ChildItem -Path $src -Recurse -File |
  Where-Object { $_.Name -in @("puzzles.json","index.json") } |
  Select-Object -ExpandProperty FullName

if (-not $candidates -or $candidates.Count -eq 0) {
  throw "No puzzles.json or index.json found under: $src"
}

$candidates | ForEach-Object { Write-Host "FOUND: $_" }

# Fix every candidate
foreach ($f in $candidates) {
  Fix-IfNeeded $f
}

Write-Host "`n--- Sanity: show first 25 lines of EACH candidate after fix ---"
foreach ($f in $candidates) {
  Write-Host "`nFILE: $f"
  Get-Content -Path $f -TotalCount 25
}

Write-Host "`n--- Runtime sanity: call backend endpoints (raw) ---"
$urls = @(
  "http://127.0.0.1:8085/health",
  "http://127.0.0.1:8085/puzzles",
  "http://127.0.0.1:8085/progress"
)

foreach ($u in $urls) {
  Write-Host "`n==== GET $u ===="
  $resp = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 10
  Write-Host "STATUS: $($resp.StatusCode)"
  Write-Host "BODY:"
  $resp.Content
}

# Return to project folder (Golden Rule)
Set-Location $root
Write-Host "`n== Phase 1 STRICT JSON fix complete. Returned to: $(Get-Location) =="
