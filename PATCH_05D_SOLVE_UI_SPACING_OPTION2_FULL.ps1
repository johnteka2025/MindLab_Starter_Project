# PATCH_05D_SOLVE_UI_SPACING_OPTION2_FULL.ps1
# Goal: Option 2 (cleaner) - wrap each main control in <div style={{ marginTop: 12 }}>...</div>
# Strict rules: canonical path, backup, guards, refuse partial edits.

$ErrorActionPreference = "Stop"

$root = "C:\Projects\MindLab_Starter_Project"
Set-Location $root

$solve = Join-Path $root "frontend\src\pages\SolvePuzzle.tsx"
if(!(Test-Path $solve)){ throw "STOP: Missing SolvePuzzle.tsx at: $solve" }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bak = "$solve.bak_$ts"
Copy-Item $solve $bak -Force
Write-Host "OK: Backup created -> $bak"

$before = Get-Content $solve -Raw

# --- GUARDS (non-negotiable) ---
$need = @(
  "<h2>Difficulty</h2>",
  "<h2>Pick a puzzle</h2>",
  "<h2>Progress</h2>"
)
foreach($n in $need){
  if($before -notmatch [regex]::Escape($n)){
    throw "STOP: Guard failed. Expected marker not found: $n"
  }
}

# We will replace specific blocks; each must match exactly once.
function Replace-Once([string]$text, [string]$anchor, [string]$replacementName, [string]$replacement){
  $count = ([regex]::Matches($text, [regex]::Escape($anchor))).Count
  if($count -ne 1){
    throw "STOP: Expected exactly 1 match for [$replacementName] anchor but found $count. Refusing to patch."
  }
  return $text.Replace($anchor, $replacement)
}

$after = $before

# --- 1) Difficulty section: wrap the <select> in a marginTop div ---
# Anchor snippet (must match exactly once)
$anchorDifficultySelect = @"
        <select
          value={difficultyFilter}
          onChange={(e) => setDifficultyFilter(e.target.value as DifficultyFilter)}
          style={{ marginBottom: "0.75rem" }}
        >
          <option value="all">All</option>
          <option value="easy">Easy</option>
          <option value="medium">Medium</option>
          <option value="hard">Hard</option>
        </select>
"@

$replacementDifficultySelect = @"
        <div style={{ marginTop: 12 }}>
          <select
            value={difficultyFilter}
            onChange={(e) => setDifficultyFilter(e.target.value as DifficultyFilter)}
            style={{ marginBottom: "0.75rem" }}
          >
            <option value="all">All</option>
            <option value="easy">Easy</option>
            <option value="medium">Medium</option>
            <option value="hard">Hard</option>
          </select>
        </div>
"@

$after = Replace-Once $after $anchorDifficultySelect "Difficulty <select>" $replacementDifficultySelect

# --- 2) Difficulty section: wrap the "difficulty not available" message in a marginTop div ---
$anchorNoDifficulty = @"
        {!difficulty && (
          <p style={{ marginTop: "0.25rem", opacity: 0.85 }}>
            â„¹ï¸ Difficulty data not available. Showing all puzzles.
          </p>
        )}
"@

$replacementNoDifficulty = @"
        <div style={{ marginTop: 12 }}>
          {!difficulty && (
            <p style={{ marginTop: "0.25rem", opacity: 0.85 }}>
              â„¹ï¸ Difficulty data not available. Showing all puzzles.
            </p>
          )}
        </div>
"@

$after = Replace-Once $after $anchorNoDifficulty "Difficulty info message" $replacementNoDifficulty

# --- 3) Pick-a-puzzle section: wrap the main puzzle <select> in a marginTop div ---
$anchorPickSelect = @"
        <select
          value={pickedPuzzleId}
          onChange={(e) => {
            const v = e.target.value ? Number(e.target.value) : "";
            setPickedPuzzleId(v);
            setPickedOptionIndex("");
            setResultMsg("");
            setDifficultyWarn(null);
          }}
        >
"@

$replacementPickSelect = @"
        <div style={{ marginTop: 12 }}>
          <select
            value={pickedPuzzleId}
            onChange={(e) => {
              const v = e.target.value ? Number(e.target.value) : "";
              setPickedPuzzleId(v);
              setPickedOptionIndex("");
              setResultMsg("");
              setDifficultyWarn(null);
            }}
          >
"@

$after = Replace-Once $after $anchorPickSelect "Pick puzzle <select> (open)" $replacementPickSelect

# Close the wrapper div after the </select> of the pick list (match exactly once)
$anchorPickSelectClose = @"
        </select>
"@

$replacementPickSelectClose = @"
          </select>
        </div>
"@

# BUT: There are multiple </select> in the file; we must anchor the CLOSE only for the pick-a-puzzle select.
# We'll do a safer localized replacement around the Pick a puzzle section.

$pickSectionStart = $after.IndexOf("<h2>Pick a puzzle</h2>")
if($pickSectionStart -lt 0){ throw "STOP: Could not locate Pick a puzzle section start." }
$pickSectionEnd = $after.IndexOf("</section>", $pickSectionStart)
if($pickSectionEnd -lt 0){ throw "STOP: Could not locate Pick a puzzle section end." }

$pickSection = $after.Substring($pickSectionStart, $pickSectionEnd - $pickSectionStart)
$closeCount = ([regex]::Matches($pickSection, [regex]::Escape($anchorPickSelectClose))).Count
if($closeCount -lt 1){
  throw "STOP: Could not find </select> inside Pick a puzzle section."
}
# Replace ONLY the first </select> after the open we already replaced in that section
$pickSection2 = $pickSection.Replace($anchorPickSelectClose, $replacementPickSelectClose, 1)

$after = $after.Substring(0, $pickSectionStart) + $pickSection2 + $after.Substring($pickSectionEnd)

# --- 4) Progress section: wrap the Refresh button in marginTop div (clean separation) ---
$anchorRefresh = @"
        <button onClick={loadAll}>Refresh</button>
"@

$replacementRefresh = @"
        <div style={{ marginTop: 12 }}>
          <button onClick={loadAll}>Refresh</button>
        </div>
"@

$after = Replace-Once $after $anchorRefresh "Progress Refresh button" $replacementRefresh

# Final guard: ensure we actually added the marginTop divs
if($after -notmatch "marginTop: 12"){
  throw "STOP: Patch produced no marginTop: 12 blocks. Refusing to write."
}

# Write UTF-8 (no BOM) like our standard approach
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($solve, $after, $utf8NoBom)

Write-Host "OK: SolvePuzzle.tsx updated with Option 2 spacing wrappers."
Write-Host "OK: Patch complete."
Write-Host "NEXT: Run sanity -> powershell -NoProfile -ExecutionPolicy Bypass -File .\RUN_FULLSTACK_SANITY.ps1"
