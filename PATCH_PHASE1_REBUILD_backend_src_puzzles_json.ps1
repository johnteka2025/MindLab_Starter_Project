# PATCH_PHASE1_REBUILD_backend_src_puzzles_json.ps1
# Rebuild backend\src\puzzles.json from a known-good source JSON file.
# Golden rules: absolute paths, backups, sanity checks, return to root.

$ErrorActionPreference = "Stop"

function Write-Section($t) {
  Write-Host ""
  Write-Host ("=" * 78)
  Write-Host $t
  Write-Host ("=" * 78)
}

function Backup-File($path, $backupDir) {
  if (-not (Test-Path $path)) { return $null }
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = Join-Path $backupDir ("{0}.bak_{1}" -f (Split-Path $path -Leaf), $stamp)
  Copy-Item -Force $path $bak
  return $bak
}

function Read-Json($path) {
  $raw = Get-Content -Path $path -Raw -Encoding UTF8
  return $raw | ConvertFrom-Json
}

function To-JsonArrayText($data) {
  # We want to output a JSON array at the root.
  # Acceptable inputs:
  # - already an array
  # - object with a .puzzles array
  if ($null -eq $data) { throw "Source JSON parsed to null." }

  if ($data -is [System.Array]) {
    $arr = $data
  }
  elseif ($data.PSObject.Properties.Name -contains "puzzles" -and $data.puzzles -is [System.Array]) {
    $arr = $data.puzzles
  }
  else {
    # If it's a single object puzzle, wrap it
    $arr = @($data)
  }

  # ConvertTo-Json sometimes compresses too shallow unless depth is high.
  return ($arr | ConvertTo-Json -Depth 20)
}

function Invoke-RawGet($url) {
  $resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $url
  return [pscustomobject]@{
    StatusCode = $resp.StatusCode
    Content    = $resp.Content
  }
}

# ---------------- MAIN ----------------
Write-Section "Phase 1 REBUILD puzzles.json starting"

$root = "C:\Projects\MindLab_Starter_Project"
if (-not (Test-Path $root)) { throw "Missing project root: $root" }
Set-Location $root
Write-Host "Root: $root"

$backupDir = Join-Path $root "backend\backups"
$target    = Join-Path $root "backend\src\puzzles.json"

# Known-good sources (priority order)
$source1 = Join-Path $root "backend\src\puzzles\puzzles.json"
$source2 = Join-Path $root "backend\src\puzzles\index.json"

$source = $null
if (Test-Path $source1) { $source = $source1 }
elseif (Test-Path $source2) { $source = $source2 }
else { throw "No known-good source found. Missing: $source1 and $source2" }

Write-Host "Target: $target"
Write-Host "Source: $source"

# Backup target if exists
$bak = Backup-File $target $backupDir
if ($bak) { Write-Host "Backed up target to: $bak" } else { Write-Host "Target did not exist; will create it." }

# Read + validate source JSON (THIS must succeed)
Write-Host "Validating source JSON parse..."
$srcData = Read-Json $source
Write-Host "OK: Source parsed."

# Build strict JSON array text
$jsonOut = To-JsonArrayText $srcData

# Quick validation: Convert back from JSON to ensure strict
Write-Host "Validating rebuilt JSON parse..."
$null = ($jsonOut | ConvertFrom-Json)
Write-Host "OK: Rebuilt JSON parses."

# Write rebuilt target
Set-Content -Path $target -Value $jsonOut -Encoding UTF8
Write-Host "WROTE: rebuilt $target"

Write-Section "Runtime sanity (raw): backend endpoints"

$urls = @(
  "http://127.0.0.1:8085/health",
  "http://127.0.0.1:8085/puzzles",
  "http://127.0.0.1:8085/progress"
)

foreach ($u in $urls) {
  Write-Host ""
  Write-Host "==== GET $u ===="
  try {
    $r = Invoke-RawGet $u
    Write-Host "STATUS: $($r.StatusCode)"
    Write-Host "BODY:"
    $r.Content
  } catch {
    Write-Host "ERROR calling $u"
    Write-Host $_.Exception.Message
    throw
  }
}

# Golden Rule: return to root
Set-Location $root
Write-Host ""
Write-Host "== Phase 1 REBUILD complete. Returned to: $(Get-Location) =="
