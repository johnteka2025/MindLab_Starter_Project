# PHASE_5A_extend_puzzles_backend.ps1
# Purpose: Extend GET /puzzles list (Phase 5) without touching ARCHIVE_PHASE_4.
# Golden rules:
# - Always run from project root
# - Always backup before modifying
# - Only modify the live file: backend\src\server.cjs
# - Return to project root at end

$ErrorActionPreference = "Stop"

function Assert-ProjectRoot($root) {
  if (-not (Test-Path (Join-Path $root "backend\src"))) { throw "Not project root (missing backend\src): $root" }
  if (-not (Test-Path (Join-Path $root "frontend\src"))) { throw "Not project root (missing frontend\src): $root" }
  if (-not (Test-Path (Join-Path $root "ARCHIVE_PHASE_4"))) { throw "Safety: missing ARCHIVE_PHASE_4 folder (freeze marker). Stop." }
}

try {
  $root = (Get-Location).Path
  Assert-ProjectRoot $root

  $server = Join-Path $root "backend\src\server.cjs"
  if (-not (Test-Path $server)) { throw "Missing file: $server" }

  # Backup
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = "$server.bak_phase5_extend_$ts"
  Copy-Item $server $bak -Force

  $raw = Get-Content $server -Raw

  # New puzzles (keep original 1-3 unchanged, add Phase 5 IDs as strings "p5-1"... to avoid collisions)
  $newArray = @'
[
  { "id": "1", "question": "What is 2 + 2?", "options": ["3","4","5"], "correctIndex": 1 },
  { "id": "2", "question": "What is the color of the sky?", "options": ["Blue","Green","Red"], "correctIndex": 0 },
  { "id": "3", "question": "Which shape has 3 sides?", "options": ["Triangle","Square","Circle"], "correctIndex": 0 },

  { "id": "p5-1", "question": "Phase 5: What planet do we live on?", "options": ["Mars","Earth","Venus"], "correctIndex": 1 },
  { "id": "p5-2", "question": "Phase 5: Which is a mammal?", "options": ["Shark","Dolphin","Trout"], "correctIndex": 1 },
  { "id": "p5-3", "question": "Phase 5: What is 10 - 6?", "options": ["2","3","4"], "correctIndex": 2 },
  { "id": "p5-4", "question": "Phase 5: Which is a primary color?", "options": ["Purple","Orange","Red"], "correctIndex": 2 },
  { "id": "p5-5", "question": "Phase 5: What comes after Wednesday?", "options": ["Tuesday","Thursday","Sunday"], "correctIndex": 1 },
  { "id": "p5-6", "question": "Phase 5: Which is a fruit?", "options": ["Carrot","Apple","Celery"], "correctIndex": 1 }
]
'@

  # Replace only inside GET /puzzles response array:
  # Match: app.get("/puzzles"... res.json( [ ... ] );
  $pattern = '(app\.get\(\s*["' + "'" + ']/puzzles["' + "'" + ']\s*,[\s\S]*?res\.json\()\s*\[[\s\S]*?\](\s*\)\s*;[\s\S]*?\}\s*\)\s*;)'
  if ($raw -notmatch $pattern) {
    throw "Could not locate a replaceable res.json([ ... ]) block inside GET /puzzles in backend\src\server.cjs. DO NOT GUESS. Run Step 5A output and paste it."
  }

  $updated = [regex]::Replace($raw, $pattern, ('$1' + $newArray + '$2'), 1)

  Set-Content -Path $server -Value $updated -Encoding UTF8

  Write-Host "PHASE_5A GREEN: Extended /puzzles list." -ForegroundColor Green
  Write-Host "Backup created: $bak" -ForegroundColor Green

} catch {
  Write-Host ("PHASE_5A ERROR: {0}" -f $_.Exception.Message) -ForegroundColor Red
  throw
} finally {
  # Return to project root
  if ($root) { Set-Location $root }
  Write-Host ("Returned to project root: {0}" -f (Get-Location).Path) -ForegroundColor Green
}
