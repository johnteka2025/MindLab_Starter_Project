# PHASE_4D_audit_progress_json.ps1
# Golden Rule: no guessing, correct paths, sanity checks, return to project root.

$ErrorActionPreference = "Stop"
$PROJECT = "C:\Projects\MindLab_Starter_Project"
Set-Location $PROJECT

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw ("Missing required {0}: {1}" -f $label, $p) }
}

$progressPath = Join-Path $PROJECT "backend\src\data\progress.json"
Assert-Path $progressPath "file"

Write-Host "=== Audit progress.json ===" -ForegroundColor Cyan
Write-Host "File: $progressPath"

# Read/parse JSON
$raw = Get-Content $progressPath -Raw -Encoding UTF8
$obj = $raw | ConvertFrom-Json

if (-not $obj) { throw "progress.json parsed to null/empty." }

# Normalize missing fields for audit display (no write)
if (-not $obj.PSObject.Properties.Match("solvedPuzzleIds")) { $obj | Add-Member -NotePropertyName solvedPuzzleIds -NotePropertyValue @{} }
if (-not $obj.PSObject.Properties.Match("solvedIds")) { $obj | Add-Member -NotePropertyName solvedIds -NotePropertyValue @() }

# Compute derived solvedIds from solvedPuzzleIds
$derived = @()
try {
  $derived = @($obj.solvedPuzzleIds.PSObject.Properties.Name)
} catch {
  $derived = @()
}

$diskSolvedIds = @()
try {
  $diskSolvedIds = @($obj.solvedIds)
} catch {
  $diskSolvedIds = @()
}

# Sort for stable compare
$derivedSorted = $derived | Sort-Object
$diskSorted = $diskSolvedIds | Sort-Object

Write-Host ("Derived solvedIds count: {0}" -f $derivedSorted.Count)
Write-Host ("Disk solvedIds count:    {0}" -f $diskSorted.Count)

if (($derivedSorted -join "|") -ne ($diskSorted -join "|")) {
  Write-Host "WARNING: solvedIds on disk does NOT match solvedPuzzleIds keys." -ForegroundColor Yellow
  Write-Host ("Derived: {0}" -f ($derivedSorted -join ", "))
  Write-Host ("Disk:    {0}" -f ($diskSorted -join ", "))
  Write-Host ""
  Write-Host "Next step (optional): run PHASE_4D_fix_progress_json.ps1 to rewrite solvedIds from solvedPuzzleIds." -ForegroundColor Yellow
} else {
  Write-Host "OK: solvedIds on disk matches solvedPuzzleIds keys." -ForegroundColor Green
}

Set-Location $PROJECT
Write-Host "Returned to project root: $PROJECT" -ForegroundColor DarkGray
