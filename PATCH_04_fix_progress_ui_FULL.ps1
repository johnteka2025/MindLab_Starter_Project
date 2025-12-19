# PATCH_04_fix_progress_ui_FULL.ps1
# Fix Progress UI + standardize backend base URL + ALWAYS return to project root

$ErrorActionPreference = "Stop"

$ROOT = "C:\Projects\MindLab_Starter_Project"
$FRONTEND = Join-Path $ROOT "frontend"
$TARGET = Join-Path $FRONTEND "src\pages\Progress.tsx"

function Write-Section($t) {
  Write-Host ""
  Write-Host "==================== $t ====================" -ForegroundColor Cyan
}

Write-Section "PATCH_04 START"
Write-Host "Root: $ROOT" -ForegroundColor Yellow
Write-Host "Target: $TARGET" -ForegroundColor Yellow

if (-not (Test-Path $ROOT)) { throw "Missing project root: $ROOT" }
if (-not (Test-Path $FRONTEND)) { throw "Missing frontend folder: $FRONTEND" }
if (-not (Test-Path $TARGET)) { throw "Missing Progress page: $TARGET" }

# Always return to a known place no matter what happens
Push-Location $ROOT
try {
  Write-Section "Backup"
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = "$TARGET.bak_$stamp"
  Copy-Item -Force $TARGET $bak
  Write-Host "Backup created: $bak" -ForegroundColor Green

  Write-Section "Write patched Progress.tsx"
  $newContent = @'
import React, { useEffect, useState } from "react";

type Progress = { total: number; solved: number };

const API_BASE =
  (import.meta as any).env?.VITE_API_BASE_URL?.toString()?.trim() ||
  "http://localhost:8085";

export default function ProgressPage() {
  const [progress, setProgress] = useState<Progress>({ total: 0, solved: 0 });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>("");

  const loadProgress = async () => {
    setLoading(true);
    setError("");
    try {
      const res = await fetch(`${API_BASE}/progress`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = (await res.json()) as Progress;
      setProgress(data);
    } catch (e: any) {
      setError(`Error loading progress: ${e?.message || "Failed to fetch"}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProgress();
  }, []);

  const completion =
    progress.total > 0 ? Math.round((progress.solved / progress.total) * 100) : 0;

  return (
    <div style={{ padding: "1rem" }}>
      <h1>Daily Progress</h1>

      {loading && <p data-testid="progress-loading">Loading...</p>}

      {error && (
        <p data-testid="progress-error" style={{ color: "red" }}>
          {error}
        </p>
      )}

      {/* IMPORTANT: This text is required for Playwright: /puzzles solved/i */}
      <p data-testid="progress-solved">
        Puzzles solved: {progress.solved} of {progress.total}
      </p>

      <p data-testid="progress-completion">Completion: {completion}%</p>

      <button
        data-testid="progress-refresh"
        style={{ marginTop: "0.75rem" }}
        onClick={loadProgress}
      >
        Refresh
      </button>
    </div>
  );
}
'@

  Set-Content -Encoding UTF8 -Path $TARGET -Value $newContent
  Write-Host "Patched successfully: $TARGET" -ForegroundColor Green

  Write-Section "Sanity check (file contains Playwright-required text)"
  $check = Select-String -Path $TARGET -Pattern "Puzzles solved:" -SimpleMatch -ErrorAction SilentlyContinue
  if (-not $check) { throw "Patch failed: 'Puzzles solved:' not found in $TARGET" }
  Write-Host "OK: Found 'Puzzles solved:' in Progress.tsx" -ForegroundColor Green

  Write-Section "Open file for visual review"
  notepad $TARGET

  Write-Section "NEXT"
  Write-Host "1) Restart frontend dev server (stop old window, then run npm run dev)." -ForegroundColor Yellow
  Write-Host "2) Open http://localhost:5177/app/progress and confirm 'Puzzles solved:' appears." -ForegroundColor Yellow
  Write-Host "3) Re-run: npx playwright test tests/e2e/mindlab-game-flow.spec.ts --trace=on --reporter=list" -ForegroundColor Yellow
}
finally {
  Pop-Location
  Set-Location $ROOT
  Write-Section "PATCH_04 END"
  Write-Host "Returned to: $(Get-Location)" -ForegroundColor Green
}
