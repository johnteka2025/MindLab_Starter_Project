# C:\Projects\MindLab_Starter_Project\PATCH_12_frontend_add_reset_progress_button.ps1
# Adds a Reset Progress button on /app/progress (calls POST /progress/reset).
# Golden Rules: absolute paths, backups, sanity build, return to project root.

$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"
$progressPage = Join-Path $frontendRoot "src\ProgressPage.tsx"

function Assert-File([string]$p) {
  if (-not (Test-Path $p)) { throw "Missing required file: $p" }
}

try {
  Assert-File $progressPage

  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $progressPage ($progressPage + ".bak_resetbtn_" + $ts) -Force
  Write-Host "Backup created: $($progressPage).bak_resetbtn_$ts" -ForegroundColor Green

  $content = @'
import React, { useEffect, useState } from "react";
import { apiGet, apiPost } from "./api";

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

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Progress</h1>

      {error && <p style={{ color: "crimson" }}>{error}</p>}

      <p>Puzzles solved: {solved} of {total}</p>
      <p>Completion: {pct}%</p>

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

  Set-Content -Path $progressPage -Value $content -Encoding UTF8
  Write-Host "Replaced: $progressPage" -ForegroundColor Green

  Set-Location $frontendRoot
  Write-Host "Running frontend build sanity..." -ForegroundColor Cyan
  npm run build

  Write-Host "PATCH_12 GREEN: Reset Progress button added." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
