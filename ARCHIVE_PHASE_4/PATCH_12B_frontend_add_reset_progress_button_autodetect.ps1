# C:\Projects\MindLab_Starter_Project\PATCH_12B_frontend_add_reset_progress_button_autodetect.ps1
# Adds Reset Progress button by auto-detecting the Progress page component file.
# Golden Rules: absolute paths, backups, sanity build, return to project root.

$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"
$srcRoot      = Join-Path $frontendRoot "src"

function Find-ProgressPageFile {
  # Prefer a file that contains the heading "Daily Progress"
  $match = Get-ChildItem $srcRoot -Recurse -File -Include *.tsx,*.ts |
    Select-String -SimpleMatch -Pattern "Daily Progress" |
    Select-Object -First 1

  if ($match) { return $match.Path }

  # Fallback: first TSX whose name contains "progress"
  $byName = Get-ChildItem $srcRoot -Recurse -File -Include *.tsx |
    Where-Object { $_.Name -match "progress" } |
    Select-Object -First 1

  if ($byName) { return $byName.FullName }

  throw "Could not locate a Progress page file in $srcRoot"
}

try {
  if (-not (Test-Path $projectRoot)) { throw "Project root not found: $projectRoot" }
  if (-not (Test-Path $frontendRoot)) { throw "Frontend root not found: $frontendRoot" }
  if (-not (Test-Path $srcRoot)) { throw "Frontend src not found: $srcRoot" }

  $progressPage = Find-ProgressPageFile
  Write-Host "Detected Progress page: $progressPage" -ForegroundColor Cyan

  # Backup
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $progressPage ($progressPage + ".bak_resetbtn_" + $ts) -Force
  Write-Host "Backup created: $($progressPage).bak_resetbtn_$ts" -ForegroundColor Green

  # Replace with a known-good ProgressPage component (uses ../api or ./api depending on location)
  # We'll compute a relative import path to api.ts based on where the file lives.
  $progressDir = Split-Path -Parent $progressPage
  $apiFile = Join-Path $srcRoot "api.ts"
  if (-not (Test-Path $apiFile)) { throw "Missing api.ts at: $apiFile" }

  $relApi = Resolve-Path $apiFile | ForEach-Object {
    # convert to relative path from progressDir
    $apiAbs = $_.Path
    $uriBase = New-Object System.Uri(($progressDir + "\"))
    $uriApi  = New-Object System.Uri($apiAbs)
    $rel = $uriBase.MakeRelativeUri($uriApi).ToString().Replace("/", "\")
    $rel = $rel -replace "\.ts$", ""
    if (-not ($rel.StartsWith("."))) { $rel = ".\" + $rel }
    $rel = $rel.Replace("\", "/")
    return $rel
  }

  $content = @"
import React, { useEffect, useState } from "react";
import { apiGet, apiPost } from "$relApi";

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
"@

  Set-Content -Path $progressPage -Value $content -Encoding UTF8
  Write-Host "Replaced: $progressPage" -ForegroundColor Green

  # Build sanity
  Set-Location $frontendRoot
  Write-Host "Running frontend build sanity..." -ForegroundColor Cyan
  npm run build

  Write-Host "PATCH_12B GREEN: Reset Progress button added." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
