$ErrorActionPreference = "Stop"

# =============================
# Phase 1 Patch (FULL)
# - Backend puzzles: add correctIndex
# - Frontend: use correctIndex (remove demo string match rules)
# - Backups + Sanity checks + Return to project root
# =============================

$root    = "C:\Projects\MindLab_Starter_Project"
$backend = Join-Path $root "backend"
$frontend= Join-Path $root "frontend"

if (-not (Test-Path $root))     { throw "Missing project root: $root" }
if (-not (Test-Path $backend))  { throw "Missing backend folder: $backend" }
if (-not (Test-Path $frontend)) { throw "Missing frontend folder: $frontend" }

function New-BackupFolder($baseFolder) {
  $b = Join-Path $baseFolder "backups"
  if (-not (Test-Path $b)) { New-Item -ItemType Directory -Path $b | Out-Null }
  return $b
}

function Backup-File($filePath, $backupDir) {
  if (-not (Test-Path $filePath)) { return $null }
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $name = Split-Path $filePath -Leaf
  $dest = Join-Path $backupDir "$name.bak_$ts"
  Copy-Item $filePath $dest -Force
  return $dest
}

function Ensure-Dir($p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

Write-Host "== Phase 1 patch starting =="
Write-Host "Root: $root"
Write-Host ""

# -----------------------------
# BACKEND: write puzzles with correctIndex
# -----------------------------
$backendBackup = New-BackupFolder $backend
$backendSrc    = Join-Path $backend "src"
if (-not (Test-Path $backendSrc)) { throw "Missing backend src: $backendSrc" }

$puzzlesDir = Join-Path $backendSrc "puzzles"
Ensure-Dir $puzzlesDir

# Canonical puzzles set (correctIndex: 0-based index into options)
# Keep it deterministic & stable for tests.
$puzzles = @(
  @{
    id = 1
    question = "What is 2 + 2?"
    options = @("3","4","5")
    correctIndex = 1
  },
  @{
    id = 2
    question = "What is the color of the sky?"
    options = @("Blue","Green","Red")
    correctIndex = 0
  },
  @{
    id = 3
    question = "Which shape has 3 sides?"
    options = @("Triangle","Square","Circle")
    correctIndex = 0
  }
)

$puzzlesJson = ($puzzles | ConvertTo-Json -Depth 10)

# Update all likely files used by server.cjs fallback logic
$puzzleFiles = @(
  (Join-Path $backendSrc "puzzles.json"),
  (Join-Path $puzzlesDir "puzzles.json"),
  (Join-Path $puzzlesDir "index.json")
)

Write-Host "---- Backend: updating puzzle JSON files ----"
foreach ($pf in $puzzleFiles) {
  $dir = Split-Path $pf -Parent
  Ensure-Dir $dir

  $bk = Backup-File $pf $backendBackup
  if ($bk) { Write-Host "Backed up: $pf -> $bk" }
  else     { Write-Host "No existing file to backup (will create): $pf" }

  Set-Content -Path $pf -Value $puzzlesJson -Encoding UTF8
  Write-Host "Wrote: $pf"
}
Write-Host ""

# -----------------------------
# FRONTEND: api.ts Puzzle type + GamePanel correctness logic
# -----------------------------
$frontendBackup = New-BackupFolder $frontend

$apiPath = Join-Path $frontend "src\api.ts"
if (-not (Test-Path $apiPath)) { throw "Missing frontend api.ts: $apiPath" }

$gamePanelPath = Join-Path $frontend "src\GamePanel.tsx"
if (-not (Test-Path $gamePanelPath)) { throw "Missing frontend GamePanel.tsx: $gamePanelPath" }

Write-Host "---- Frontend: patch api.ts Puzzle type (add correctIndex?) ----"
$apiBk = Backup-File $apiPath $frontendBackup
Write-Host "Backed up: $apiPath -> $apiBk"

$apiRaw = Get-Content $apiPath -Raw

# Try to minimally add "correctIndex?: number;" inside the exported Puzzle type/interface.
# We support either: export type Puzzle = { ... } OR export interface Puzzle { ... }
if ($apiRaw -match 'export\s+type\s+Puzzle\s*=\s*\{') {
  if ($apiRaw -notmatch 'correctIndex\??\s*:\s*number') {
    # Insert after options line if present; otherwise insert near top of type block
    if ($apiRaw -match 'export\s+type\s+Puzzle\s*=\s*\{[\s\S]*?options\s*:\s*string\[\]\s*;') {
      $apiRaw = [regex]::Replace(
        $apiRaw,
        '(export\s+type\s+Puzzle\s*=\s*\{[\s\S]*?options\s*:\s*string\[\]\s*;)',
        "`$1`r`n  correctIndex?: number;"
      , 1)
    } else {
      $apiRaw = [regex]::Replace(
        $apiRaw,
        '(export\s+type\s+Puzzle\s*=\s*\{)',
        "`$1`r`n  correctIndex?: number;"
      , 1)
    }
    Write-Host "Added correctIndex?: number to export type Puzzle"
  } else {
    Write-Host "Puzzle type already contains correctIndex"
  }
}
elseif ($apiRaw -match 'export\s+interface\s+Puzzle\s*\{') {
  if ($apiRaw -notmatch 'correctIndex\??\s*:\s*number') {
    if ($apiRaw -match 'export\s+interface\s+Puzzle\s*\{[\s\S]*?options\s*:\s*string\[\]\s*;') {
      $apiRaw = [regex]::Replace(
        $apiRaw,
        '(export\s+interface\s+Puzzle\s*\{[\s\S]*?options\s*:\s*string\[\]\s*;)',
        "`$1`r`n  correctIndex?: number;"
      , 1)
    } else {
      $apiRaw = [regex]::Replace(
        $apiRaw,
        '(export\s+interface\s+Puzzle\s*\{)',
        "`$1`r`n  correctIndex?: number;"
      , 1)
    }
    Write-Host "Added correctIndex?: number to export interface Puzzle"
  } else {
    Write-Host "Puzzle interface already contains correctIndex"
  }
}
else {
  throw "Could not find exported Puzzle type/interface in api.ts to patch safely."
}

Set-Content -Path $apiPath -Value $apiRaw -Encoding UTF8
Write-Host ""

Write-Host "---- Frontend: replace GamePanel.tsx correctness logic (use correctIndex) ----"
$gpBk = Backup-File $gamePanelPath $frontendBackup
Write-Host "Backed up: $gamePanelPath -> $gpBk"

# Full replacement of GamePanel.tsx (safe + deterministic)
# - Uses backend puzzle.correctIndex
# - Calls solvePuzzle only on correct
# - Prevents double-solve for same id in-session
$gamePanelContent = @'
import React, { useEffect, useMemo, useState } from "react";
import { getPuzzles, solvePuzzle, type Puzzle } from "./api";

/**
 * GamePanel (SOURCE OF TRUTH)
 * - Reads puzzles from backend: GET /puzzles
 * - When user answers correctly (data-driven via correctIndex), records it: POST /progress/solve
 * - Keeps UI simple + deterministic
 *
 * NOTE:
 * - correctIndex is 0-based index into options
 * - If correctIndex is missing, we treat the puzzle as "unknown correctness" (never auto-solve)
 */

function isCorrectAnswer(p: Puzzle, pickedIndex: number): boolean {
  if (typeof p.correctIndex !== "number") return false;
  return pickedIndex === p.correctIndex;
}

const GamePanel: React.FC = () => {
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [status, setStatus] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // prevent double-solve for same puzzle in this session
  const [solvedIds, setSolvedIds] = useState<Record<string, true>>({});

  async function loadPuzzles() {
    setLoading(true);
    setStatus(null);
    try {
      const result = await getPuzzles();
      const list = result || [];
      setPuzzles(list);
      setCurrentIndex(0);
      if (list.length === 0) setStatus("No puzzles available.");
    } catch (e) {
      setStatus("Failed to load puzzles.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadPuzzles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const currentPuzzle = useMemo(() => puzzles[currentIndex], [puzzles, currentIndex]);

  async function handleOptionClick(pickedIndex: number) {
    if (!currentPuzzle) return;

    const correct = isCorrectAnswer(currentPuzzle, pickedIndex);

    if (correct) {
      setStatus("Correct!");
      const id = String((currentPuzzle as any).id ?? "unknown");

      // only solve once per id per session
      if (!solvedIds[id]) {
        setSolvedIds((prev) => ({ ...prev, [id]: true }));
        try {
          await solvePuzzle(id);
        } catch {
          // Keep UI stable even if solve fails
        }
      }
    } else {
      setStatus("Try again.");
    }
  }

  function nextPuzzle() {
    if (puzzles.length === 0) return;
    setStatus(null);
    setCurrentIndex((i) => (i + 1) % puzzles.length);
  }

  return (
    <section aria-label="Puzzles section">
      <h2>Puzzles</h2>

      {loading && <div aria-live="polite">Loading puzzles…</div>}

      {!loading && !currentPuzzle && (
        <div aria-live="polite">
          <p>No puzzle loaded.</p>
          <button type="button" onClick={loadPuzzles}>
            Reload puzzles
          </button>
        </div>
      )}

      {currentPuzzle && (
        <>
          <p>{currentPuzzle.question}</p>
          <ul>
            {currentPuzzle.options.map((opt: string, idx: number) => (
              <li key={idx}>
                <button type="button" onClick={() => handleOptionClick(idx)}>
                  {opt}
                </button>
              </li>
            ))}
          </ul>

          <button type="button" onClick={nextPuzzle}>
            Next puzzle
          </button>
        </>
      )}

      {status && (
        <div role="status" aria-live="polite" style={{ marginTop: "0.75rem" }}>
          {status}
        </div>
      )}
    </section>
  );
};

export default GamePanel;
'@

Set-Content -Path $gamePanelPath -Value $gamePanelContent -Encoding UTF8
Write-Host "Replaced: $gamePanelPath"
Write-Host ""

# -----------------------------
# Sanity checks
# -----------------------------
Write-Host "---- Sanity: Backend tests ----"
Push-Location $backend
npm test
Pop-Location
Write-Host ""

Write-Host "---- Sanity: Frontend typecheck (no emit) ----"
Push-Location $frontend
npx tsc -p .\tsconfig.json --noEmit
Pop-Location
Write-Host ""

Write-Host "---- Sanity: Frontend tests ----"
Push-Location $frontend
npm test
Pop-Location
Write-Host ""

# -----------------------------
# Golden Rule: return to project root
# -----------------------------
Set-Location $root
Write-Host ""
Write-Host "== Phase 1 patch complete. Returned to: $(Get-Location) =="
