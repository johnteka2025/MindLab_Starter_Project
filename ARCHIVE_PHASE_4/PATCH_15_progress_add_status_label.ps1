# C:\Projects\MindLab_Starter_Project\PATCH_15_progress_add_status_label.ps1
# Step 3.4A(2): Add status label on Progress page.
# Golden Rules: absolute paths, backups, sanity build, return to project root.

$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"
$progressFile = Join-Path $frontendRoot "src\pages\Progress.tsx"

function Assert-PathExists([string]$p) {
  if (-not (Test-Path $p)) { throw "Missing required path: $p" }
}

try {
  Assert-PathExists $projectRoot
  Assert-PathExists $frontendRoot
  Assert-PathExists $progressFile

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $progressFile ($progressFile + ".bak_status_" + $ts) -Force
  Write-Host "Backup created: $($progressFile).bak_status_$ts" -ForegroundColor Green

  $src = Get-Content $progressFile -Raw

  # If this file was previously replaced by PATCH_12B, it's a simple component.
  # We replace it fully with a known-good version that includes the Reset button + status label.
  $content = @'
import React, { useEffect, useState } from "react";
import { apiGet, apiPost } from "../api";

type Progress = {
  total: number;
  solved: number;
  solvedIds?: Array<string | number>;
};

export default function ProgressPage() {
  const [progress, setProgress] = useState<Progress | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function load() {
    setError(null);
    try {
      const p = await apiGet<Progress>("/progress");
      setProgress(p);
    } catch (e: any) {
      setError(e?.message ?? "Failed to load progress.");
    }
  }

  async function resetProgress() {
    setBusy(true);
    setError(null);
    try {
      await apiPost("/progress/reset", {});
      await load();
    } catch (e: any) {
      setError(e?.message ?? "Failed to reset progress.");
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  const total = progress?.total ?? 0;
  const solved = progress?.solved ?? 0;
  const pct = total > 0 ? Math.round((solved / total) * 100) : 0;

  const statusText =
    total <= 0 ? "Status: Unknown" :
    solved <= 0 ? "Status: Not started" :
    solved < total ? "Status: In progress" :
    "Status: Complete";

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Progress</h1>

      {error && <p style={{ color: "crimson" }}>{error}</p>}

      <p>Puzzles solved: {solved} of {total}</p>
      <p>Completion: {pct}%</p>
      <p data-testid="progress-status">{statusText}</p>

      <button type="button" onClick={load} disabled={busy}>
        Refresh
      </button>

      <button
        type="button"
        onClick={resetProgress}
        disabled={busy}
        style={{ marginLeft: 8 }}
      >
        {busy ? "Resetting..." : "Reset Progress"}
      </button>
    </div>
  );
}
'@

  Set-Content -Path $progressFile -Value $content -Encoding UTF8
  Write-Host "Replaced file: $progressFile" -ForegroundColor Green

  Set-Location $frontendRoot
  Write-Host "Running frontend build sanity..." -ForegroundColor Cyan
  npm run build

  Write-Host "PATCH_15 GREEN: Progress status label added." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
