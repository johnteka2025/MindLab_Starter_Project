# PHASE_4D_fix_progress_json.ps1
# Rewrites backend\src\data\progress.json so solvedIds is derived from solvedPuzzleIds.
# Golden Rule: backups + sanity + return to root.

$ErrorActionPreference = "Stop"
$PROJECT = "C:\Projects\MindLab_Starter_Project"
Set-Location $PROJECT

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw ("Missing required {0}: {1}" -f $label, $p) }
}

$progressPath = Join-Path $PROJECT "backend\src\data\progress.json"
Assert-Path $progressPath "file"

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$progressPath.bak_fix_solvedIds_$ts"
Copy-Item $progressPath $bak -Force
Write-Host "Backup created: $bak" -ForegroundColor Green

$raw = Get-Content $progressPath -Raw -Encoding UTF8
$obj = $raw | ConvertFrom-Json
if (-not $obj) { throw "progress.json parsed to null/empty." }

if (-not $obj.PSObject.Properties.Match("solvedPuzzleIds")) { $obj | Add-Member -NotePropertyName solvedPuzzleIds -NotePropertyValue @{} }

# Derive solvedIds from solvedPuzzleIds keys
$derived = @()
try { $derived = @($obj.solvedPuzzleIds.PSObject.Properties.Name) } catch { $derived = @() }
$derived = $derived | Sort-Object

# Set solvedIds to derived
if ($obj.PSObject.Properties.Match("solvedIds")) {
  $obj.solvedIds = @($derived)
} else {
  $obj | Add-Member -NotePropertyName solvedIds -NotePropertyValue @($derived)
}

# Write back pretty JSON
$json = $obj | ConvertTo-Json -Depth 10
Set-Content -Path $progressPath -Value $json -Encoding UTF8

Write-Host "Updated: $progressPath" -ForegroundColor Green
Write-Host ("solvedIds now: {0}" -f ($derived -join ", "))

# Sanity re-read
$raw2 = Get-Content $progressPath -Raw -Encoding UTF8
$obj2 = $raw2 | ConvertFrom-Json
$disk = @($obj2.solvedIds) | Sort-Object
$keys = @($obj2.solvedPuzzleIds.PSObject.Properties.Name) | Sort-Object

if (($disk -join "|") -ne ($keys -join "|")) {
  throw "Sanity failed: solvedIds still does not match solvedPuzzleIds keys after write."
}

Write-Host "SANITY OK: solvedIds matches solvedPuzzleIds keys." -ForegroundColor Green
Set-Location $PROJECT
Write-Host "Returned to project root: $PROJECT" -ForegroundColor DarkGray
