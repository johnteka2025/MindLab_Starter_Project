# PHASE_5B_extend_puzzles_list.ps1
# Phase 5: Expand /puzzles list WITHOUT touching Phase 4 persistence.
# Golden Rules:
# - Always run from project root
# - Never modify anything under .\ARCHIVE_PHASE_4\
# - Always create backups before editing
# - Use stable, unique puzzle ids (no collisions with "1","2","3","demo-1")

$ErrorActionPreference = "Stop"

$root = (Resolve-Path ".").Path
if (-not (Test-Path "$root\ARCHIVE_PHASE_4")) { throw "Phase 4 freeze folder missing: $root\ARCHIVE_PHASE_4" }

$server = Join-Path $root "backend\src\server.cjs"
if (-not (Test-Path $server)) { throw "Missing file: $server" }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$server.bak_phase5_$ts"
Copy-Item $server $bak -Force

# Read file
$txt = Get-Content $server -Raw -Encoding UTF8

# We expect a puzzles array like: const PUZZLES = [ ... ];
# We'll insert new items just before the first closing "];" after "const PUZZLES".
$idxConst = $txt.IndexOf("const PUZZLES")
if ($idxConst -lt 0) { throw "Could not find 'const PUZZLES' in server.cjs. Manual edit required." }

# Find the closing bracket of that array (first occurrence of "];" AFTER const PUZZLES)
$idxClose = $txt.IndexOf("];", $idxConst)
if ($idxClose -lt 0) { throw "Could not find closing '];' for PUZZLES array. Manual edit required." }

# Phase 5 puzzles (stable ids; do NOT reuse existing ids)
# Keep the schema consistent with existing entries: { id, question, answer } (and category if supported)
$phase5Block = @"
,
  { id: "p5-001", question: "What planet is known as the Red Planet?", answer: "mars", category: "space" },
  { id: "p5-002", question: "How many minutes are in 2 hours?", answer: "120", category: "math" },
  { id: "p5-003", question: "What gas do plants absorb from the air?", answer: "carbon dioxide", category: "science" },
  { id: "p5-004", question: "What is the opposite of 'cold'?", answer: "hot", category: "words" },
  { id: "p5-005", question: "How many sides does a square have?", answer: "4", category: "shapes" }
"@

# Inject before array close
$newTxt = $txt.Insert($idxClose, $phase5Block)

# Write back
Set-Content -Path $server -Value $newTxt -Encoding UTF8

Write-Host "PHASE_5B GREEN: Updated $server" -ForegroundColor Green
Write-Host "Backup created: $bak" -ForegroundColor Green

# Sanity check: ensure no duplicate ids in the file (basic check)
$ids = @()
$ids += (Select-String -Path $server -Pattern 'id:\s*"' -AllMatches).Matches.Value
if ($ids.Count -eq 0) {
  Write-Host "WARNING: Could not extract any ids for sanity check (pattern mismatch)." -ForegroundColor Yellow
} else {
  Write-Host "PHASE_5B: Basic id lines found: $($ids.Count)" -ForegroundColor Green
}

Write-Host ("Returned to project root: {0}" -f $root) -ForegroundColor Green
Set-Location $root
