# PATCH_PHASE1_STRICT_fix_puzzles_json_ALL_v2.ps1
# Goal: Ensure backend puzzle JSON files are STRICT JSON arrays ([])
# Golden Rules:
# - Always use absolute paths
# - Always backup before writing
# - Always run sanity checks
# - Always return to project root at end

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

function Test-StrictJson($text) {
  # Strict JSON parse (System.Text.Json)
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $reader = New-Object System.Text.Json.Utf8JsonReader($bytes)
    # JsonDocument.Parse requires ReadOnlySpan<byte>
    $doc = [System.Text.Json.JsonDocument]::Parse($bytes)
    $doc.Dispose()
    return $true
  } catch {
    return $false
  }
}

function Normalize-JsonString($raw) {
  if ($null -eq $raw) { return "" }
  $t = $raw.Trim()

  # Remove trailing commas before } or ]
  $t = [regex]::Replace($t, ",\s*([}\]])", '$1')

  return $t
}

function Fix-ToJsonArrayIfPossible($raw) {
  $t = Normalize-JsonString $raw

  if ($t -eq "") { return $t }

  # If already an array, keep
  if ($t.StartsWith("[")) {
    return $t
  }

  # If it looks like one or more top-level objects, wrap into array.
  # Also handle cases where objects are adjacent without commas:
  #   } {   => split boundary and insert comma.
  if ($t.StartsWith("{")) {
    # Insert commas between adjacent objects if missing
    $t2 = [regex]::Replace($t, "}\s*{", "},{")
    $wrapped = "[" + $t2 + "]"
    return $wrapped
  }

  # Otherwise, don't guess
  return $t
}

function Ensure-StrictJsonArrayFile($path, $backupDir) {
  Write-Host ""
  Write-Host "---- Checking: $path ----"

  if (-not (Test-Path $path)) {
    Write-Host "SKIP: file not found."
    return
  }

  $raw = Get-Content -Path $path -Raw -Encoding UTF8
  $rawNorm = Normalize-JsonString $raw

  # Already strict JSON?
  if (Test-StrictJson $rawNorm) {
    # Must also be an array at root
    $rootChar = $rawNorm.TrimStart().Substring(0,1)
    if ($rootChar -eq "[") {
      Write-Host "OK: strict JSON array already."
      return
    } else {
      Write-Host "WARN: strict JSON but NOT array root. Will attempt wrap."
    }
  } else {
    Write-Host "INFO: Not strict JSON. Will attempt repair."
  }

  $candidate = Fix-ToJsonArrayIfPossible $rawNorm
  $candidate = Normalize-JsonString $candidate

  if (-not (Test-StrictJson $candidate)) {
    Write-Host "ERROR: Auto-fix failed strict JSON parse."
    Write-Host "       Not writing changes to disk."
    throw "Strict JSON parse still failing for: $path"
  }

  # Ensure array root after fix
  $rootChar2 = $candidate.TrimStart().Substring(0,1)
  if ($rootChar2 -ne "[") {
    Write-Host "ERROR: After fix, root is not array. Not writing."
    throw "Root is not JSON array for: $path"
  }

  $bak = Backup-File $path $backupDir
  Write-Host "Backed up to: $bak"

  Set-Content -Path $path -Value $candidate -Encoding UTF8
  Write-Host "FIXED: wrote strict JSON array."
}

function Get-JsonCandidates($root) {
  $candidates = @()

  # canonical locations
  $c1 = Join-Path $root "backend\src\puzzles.json"
  $c2 = Join-Path $root "backend\src\puzzles\index.json"
  $c3 = Join-Path $root "backend\src\puzzles\puzzles.json"

  foreach ($p in @($c1,$c2,$c3)) {
    if (Test-Path $p) { $candidates += $p }
  }

  # also search for any puzzles*.json under backend\src\puzzles
  $dir = Join-Path $root "backend\src\puzzles"
  if (Test-Path $dir) {
    $more = Get-ChildItem -Path $dir -Filter "*.json" -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    foreach ($m in $more) {
      if ($candidates -notcontains $m) { $candidates += $m }
    }
  }

  return $candidates
}

function Invoke-RawGet($url) {
  # Invoke-RestMethod doesn't have -Raw; use Invoke-WebRequest for raw text
  $resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $url
  return [pscustomobject]@{
    StatusCode = $resp.StatusCode
    Content    = $resp.Content
  }
}

# -------------------- MAIN --------------------
Write-Section "== Phase 1 STRICT JSON fix (v2) starting =="

$root = "C:\Projects\MindLab_Starter_Project"
if (-not (Test-Path $root)) { throw "Missing project root: $root" }

Set-Location $root
Write-Host "Root: $root"

$backupDir = Join-Path $root "backend\backups"
$candidates = Get-JsonCandidates $root

Write-Host ""
Write-Host "-- Candidate puzzle JSON files --"
$candidates | ForEach-Object { Write-Host ("FOUND: " + $_) }

if ($candidates.Count -eq 0) {
  throw "No candidate puzzles JSON files found under backend\src"
}

# Fix each
foreach ($f in $candidates) {
  Ensure-StrictJsonArrayFile -path $f -backupDir $backupDir
}

Write-Section "Runtime sanity (raw) - backend endpoints"

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

# Golden Rule: return to project root
Set-Location $root
Write-Host ""
Write-Host "== Phase 1 STRICT JSON fix (v2) complete. Returned to: $(Get-Location) =="
