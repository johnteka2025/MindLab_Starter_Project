# C:\Projects\MindLab_Starter_Project\PATCH_11_backend_progress_persistence.ps1
# Phase 4: Persist progress to disk so it survives backend restarts.
# Golden Rules: absolute paths, backups, sanity checks, return to project root.

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$backendSrc  = Join-Path $projectRoot "backend\src"
$filePath    = Join-Path $backendSrc "progressRoutes.cjs"
$dataDir     = Join-Path $backendSrc ".data"
$dataFile    = Join-Path $dataDir "progress.json"

function Assert-PathExists([string]$p) {
  if (-not (Test-Path $p)) { throw "Missing path: $p" }
}

try {
  Assert-PathExists $projectRoot
  Assert-PathExists $backendSrc
  Assert-PathExists $filePath

  # Backup
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $filePath ($filePath + ".bak_persist_" + $ts) -Force
  Write-Host "Backup created: $($filePath).bak_persist_$ts" -ForegroundColor Green

  # Ensure data directory exists
  if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir | Out-Null
    Write-Host "Created: $dataDir" -ForegroundColor Green
  }

  # Replace progressRoutes.cjs with full persisted version
  $content = @'
"use strict";

const fs = require("fs");
const path = require("path");

module.exports = function (app) {
  const dataDir = path.join(__dirname, ".data");
  const dataFile = path.join(dataDir, "progress.json");

  function ensureDataDir() {
    try {
      if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });
    } catch {
      // ignore
    }
  }

  function defaultProgress() {
    return {
      total: 0, // computed dynamically
      solved: 0,
      solvedToday: 0,
      totalSolved: 0,
      streak: 0,
      solvedPuzzleIds: {},
    };
  }

  function loadProgressFromDisk() {
    ensureDataDir();
    try {
      if (!fs.existsSync(dataFile)) return null;
      const raw = fs.readFileSync(dataFile, "utf8");
      const parsed = JSON.parse(raw);
      if (!parsed || typeof parsed !== "object") return null;
      return parsed;
    } catch {
      return null;
    }
  }

  function saveProgressToDisk(progressObj) {
    ensureDataDir();
    try {
      fs.writeFileSync(dataFile, JSON.stringify(progressObj, null, 2), "utf8");
    } catch {
      // ignore (we keep app working even if disk write fails)
    }
  }

  // Single source of truth stored on globalThis so all routes share it
  if (!globalThis.__mindlabProgress) {
    const loaded = loadProgressFromDisk();
    globalThis.__mindlabProgress = loaded || defaultProgress();
  }

  function readPuzzlesCount() {
    // Align with server.cjs candidates (avoid drift)
    const candidates = [
      path.join(__dirname, "index.json"),
      path.join(__dirname, "puzzles", "index.json"),
      path.join(__dirname, "puzzles.json"),
      path.join(__dirname, "puzzles", "legacy", "puzzles.json"),
    ];

    for (const p of candidates) {
      try {
        if (!fs.existsSync(p)) continue;
        const raw = fs.readFileSync(p, "utf8");
        const data = JSON.parse(raw);
        const puzzles = Array.isArray(data)
          ? data
          : Array.isArray(data.puzzles)
          ? data.puzzles
          : [];
        if (Array.isArray(puzzles)) return puzzles.length;
      } catch {
        // ignore and try next
      }
    }
    // fallback matches server.cjs fallback list size
    return 2;
  }

  function clampProgress() {
    const p = globalThis.__mindlabProgress;

    const computedTotal = readPuzzlesCount();
    p.total = typeof computedTotal === "number" ? computedTotal : 2;

    if (typeof p.solved !== "number") p.solved = 0;
    if (p.total < 0) p.total = 0;
    if (p.solved < 0) p.solved = 0;
    if (p.solved > p.total) p.solved = p.total;

    if (typeof p.solvedToday !== "number") p.solvedToday = 0;
    if (typeof p.totalSolved !== "number") p.totalSolved = 0;
    if (typeof p.streak !== "number") p.streak = 0;

    if (!p.solvedPuzzleIds || typeof p.solvedPuzzleIds !== "object") {
      p.solvedPuzzleIds = {};
    }
  }

  function solvedIdsArray() {
    const p = globalThis.__mindlabProgress;
    return Object.keys(p.solvedPuzzleIds || {});
  }

  function persist() {
    // Save only stable fields (total is computed anyway, but harmless to store)
    try {
      const p = globalThis.__mindlabProgress;
      saveProgressToDisk(p);
    } catch {
      // ignore
    }
  }

  function doSolve(req, res) {
    try {
      clampProgress();
      const p = globalThis.__mindlabProgress;

      const body = req.body || {};
      const puzzleId = body.puzzleId || body.id || body.puzzle || null;

      if (puzzleId && !p.solvedPuzzleIds[puzzleId]) {
        p.solvedPuzzleIds[puzzleId] = true;
        p.solved = Math.min(p.total, p.solved + 1);
        p.solvedToday += 1;
        p.totalSolved += 1;
      } else if (!puzzleId) {
        p.solved = Math.min(p.total, p.solved + 1);
        p.solvedToday += 1;
        p.totalSolved += 1;
      }

      clampProgress();
      persist();

      return res.status(200).json({
        ok: true,
        puzzleId: puzzleId,
        progress: {
          total: p.total,
          solved: p.solved,
          solvedToday: p.solvedToday,
          totalSolved: p.totalSolved,
          streak: p.streak,
          solvedIds: solvedIdsArray(),
        },
      });
    } catch (e) {
      return res.status(500).json({ ok: false, error: String(e) });
    }
  }

  app.get("/progress", (_req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;
    return res.json({
      total: p.total,
      solved: p.solved,
      solvedIds: solvedIdsArray(),
    });
  });

  app.post("/progress/solve", (req, res) => doSolve(req, res));

  app.post("/progress", (req, res) => {
    clampProgress();
    const p = globalThis.__mindlabProgress;

    const body = req.body || {};
    if (body.correct === true) {
      p.solved = Math.min(p.total, p.solved + 1);
    }

    clampProgress();
    persist();

    return res.json({
      total: p.total,
      solved: p.solved,
      solvedIds: solvedIdsArray(),
    });
  });

  app.post("/progress/reset", (_req, res) => {
    globalThis.__mindlabProgress = defaultProgress();
    clampProgress();
    persist();
    const p = globalThis.__mindlabProgress;
    return res.json({ ok: true, total: p.total, solved: p.solved, solvedIds: [] });
  });
};
'@

  Set-Content -Path $filePath -Value $content -Encoding UTF8
  Write-Host "Replaced: $filePath" -ForegroundColor Green

  Write-Host "PATCH_11 READY: restart backend next for verification." -ForegroundColor Yellow
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
