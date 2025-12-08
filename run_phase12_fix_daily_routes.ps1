param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 12.1 - Fix Daily routes (/daily*) ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) { Write-Host "Trace mode: ON" -ForegroundColor Yellow }

# -----------------------
# Paths and basic checks
# -----------------------
$backendDir = Join-Path $root "backend"
$srcDir     = Join-Path $backendDir "src"
$dailyDir   = Join-Path $srcDir "daily-challenge"

if (-not (Test-Path $backendDir)) {
    Write-Host ("ERROR: Backend folder not found: {0}" -f $backendDir) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12.1: FAILED (missing backend folder)" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $srcDir   -Force | Out-Null
New-Item -ItemType Directory -Path $dailyDir -Force | Out-Null

$engineJsPath  = Join-Path $dailyDir "dailyChallengeEngine.cjs"
$routesJsPath  = Join-Path $dailyDir "dailyChallengeRoutes.cjs"
$serverCjsPath = Join-Path $srcDir  "server.cjs"

if (-not (Test-Path $serverCjsPath)) {
    Write-Host ("ERROR: server.cjs not found at: {0}" -f $serverCjsPath) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12.1: FAILED (missing server.cjs)" -ForegroundColor Red
    exit 1
}

# -----------------------
# STEP 1 - Backup server.cjs
# -----------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = Join-Path $srcDir ("server_before_daily_" + $timestamp + ".cjs")

Copy-Item -Path $serverCjsPath -Destination $backupPath -Force
Write-Host ("Backup of server.cjs created at: {0}" -f $backupPath) -ForegroundColor Yellow

# -----------------------
# STEP 2 - Recreate Daily engine JS
# -----------------------
Write-Host ""
Write-Host "STEP 2 - Recreating dailyChallengeEngine.cjs" -ForegroundColor Cyan

$engineJsContent = @"
/**
 * Daily Challenge backend core logic (CommonJS).
 */

const BAND_CONFIG = {
  A: { band: "A", puzzleCount: 3 },
  B: { band: "B", puzzleCount: 4 },
  C: { band: "C", puzzleCount: 5 },
};

function getTodayKey(date = new Date()) {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, "0");
  const d = String(date.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function generateDailyChallengeId(userKey, dateKey) {
  return `${userKey}:${dateKey}`;
}

function createDailyChallengeInstance(userKey, band, dateKey, puzzles) {
  const total = puzzles.length;
  const id = generateDailyChallengeId(userKey, dateKey);

  return {
    dailyChallengeId: id,
    band,
    challengeDate: dateKey,
    totalPuzzles: total,
    completedCount: 0,
    status: total > 0 ? "not_started" : "completed",
    puzzles,
  };
}

function deriveStatus(instance, streakCount) {
  return {
    status: instance.status,
    streakCount,
    puzzlesCompletedToday: instance.completedCount,
    totalPuzzlesForToday: instance.totalPuzzles,
    band: instance.band,
    challengeDate: instance.challengeDate,
  };
}

function applyAnswer(instance, puzzleId, correct, currentStreakCount) {
  const updated = {
    ...instance,
    puzzles: [...instance.puzzles],
  };

  if (correct) {
    if (updated.status !== "completed") {
      updated.completedCount = Math.min(
        updated.completedCount + 1,
        updated.totalPuzzles
      );
    }
  }

  if (updated.totalPuzzles > 0 && updated.completedCount >= updated.totalPuzzles) {
    updated.status = "completed";
  } else if (updated.completedCount > 0) {
    updated.status = "in_progress";
  } else {
    updated.status = "not_started";
  }

  let newStreak = currentStreakCount;

  if (instance.status !== "completed" && updated.status === "completed") {
    newStreak = currentStreakCount + 1;
  }

  return {
    instance: updated,
    correct,
    streakCount: newStreak,
  };
}

module.exports = {
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
};
"@

Set-Content -Path $engineJsPath -Value $engineJsContent -Encoding UTF8
Write-Host ("Created/updated: {0}" -f $engineJsPath) -ForegroundColor Green

# -----------------------
# STEP 3 - Recreate Daily routes JS
# -----------------------
Write-Host ""
Write-Host "STEP 3 - Recreating dailyChallengeRoutes.cjs" -ForegroundColor Cyan

$routesJsContent = @"
const express = require("express");
const {
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
} = require("./dailyChallengeEngine.cjs");

// In-memory store: userKey -> { instanceByDate, streakCount }
const userStore = {};

function getUserKey(req) {
  // Later: derive from auth; for now a demo user.
  return "demo-user";
}

function getBandForUser(req) {
  // Later: user preference; for now fixed band B.
  return "B";
}

function getOrCreateUserState(userKey) {
  let state = userStore[userKey];
  if (!state) {
    state = { instanceByDate: {}, streakCount: 0 };
    userStore[userKey] = state;
  }
  return state;
}

function generatePuzzlesForBand(band, dateKey) {
  const config = BAND_CONFIG[band] || BAND_CONFIG["B"];
  const count = config.puzzleCount;
  const puzzles = [];

  for (let i = 1; i <= count; i++) {
    puzzles.push({
      id: `${dateKey}-${band}-${i}`,
      title: `Daily Puzzle ${i}`,
      type: "demo",
      difficulty: i,
    });
  }

  return puzzles;
}

function getOrCreateInstanceForToday(userKey, band, dateKey) {
  const state = getOrCreateUserState(userKey);
  let instance = state.instanceByDate[dateKey];

  if (!instance) {
    const puzzles = generatePuzzlesForBand(band, dateKey);
    instance = createDailyChallengeInstance(userKey, band, dateKey, puzzles);
    state.instanceByDate[dateKey] = instance;
  }

  return { state, instance };
}

function createDailyChallengeRouter() {
  const router = express.Router();

  // GET /daily/status
  router.get("/daily/status", (req, res) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    const status = deriveStatus(instance, state.streakCount);
    return res.status(200).json(status);
  });

  // GET /daily
  router.get("/daily", (req, res) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    void state; // unused here

    return res.status(200).json(instance);
  });

  // POST /daily/answer
  router.post("/daily/answer", (req, res) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    const body = req.body || {};
    const dailyChallengeId = body.dailyChallengeId;
    const puzzleId = body.puzzleId;

    if (!puzzleId) {
      return res.status(400).json({
        error: "ValidationError",
        message: "puzzleId is required",
      });
    }

    if (dailyChallengeId && dailyChallengeId !== instance.dailyChallengeId) {
      return res.status(400).json({
        error: "DailyChallengeNotFound",
        message: "dailyChallengeId does not match today's challenge",
      });
    }

    // Phase 1: treat all answers as correct.
    const correct = true;

    const result = applyAnswer(
      instance,
      puzzleId,
      correct,
      state.streakCount
    );

    state.instanceByDate[dateKey] = result.instance;
    state.streakCount = result.streakCount;

    return res.status(200).json({
      dailyChallengeId: result.instance.dailyChallengeId,
      puzzleId,
      correct: result.correct,
      completedCount: result.instance.completedCount,
      totalPuzzles: result.instance.totalPuzzles,
      status: result.instance.status,
      streakCount: result.streakCount,
    });
  });

  return router;
}

module.exports = {
  createDailyChallengeRouter,
};
"@

Set-Content -Path $routesJsPath -Value $routesJsContent -Encoding UTF8
Write-Host ("Created/updated: {0}" -f $routesJsPath) -ForegroundColor Green

# -----------------------
# STEP 4 - Wire server.cjs (require + app.use)
# -----------------------
Write-Host ""
Write-Host "STEP 4 - Wiring Daily router into server.cjs" -ForegroundColor Cyan

$serverLines = Get-Content $serverCjsPath

$requireLine = 'const { createDailyChallengeRouter } = require("./daily-challenge/dailyChallengeRoutes.cjs");'
$appUseLine  = 'app.use(createDailyChallengeRouter());'

# 4a) Insert require(...) after last require()
if (-not ($serverLines -match 'createDailyChallengeRouter')) {
    if ($TraceOn) { Write-Host "Inserting require(...) line..." -ForegroundColor Yellow }

    $lastRequireIndex = -1
    for ($i = 0; $i -lt $serverLines.Length; $i++) {
        if ($serverLines[$i] -match 'require\(') {
            $lastRequireIndex = $i
        }
    }

    $new = @()
    if ($lastRequireIndex -ge 0) {
        for ($i = 0; $i -lt $serverLines.Length; $i++) {
            $new += $serverLines[$i]
            if ($i -eq $lastRequireIndex) {
                $new += $requireLine
            }
        }
    } else {
        $new = @($requireLine, "") + $serverLines
    }

    $serverLines = $new
} else {
    Write-Host "Require for createDailyChallengeRouter already exists." -ForegroundColor Yellow
}

# 4b) Insert app.use(...) after last app.use(...) if possible, else after const app, else at end
if (-not ($serverLines -match 'createDailyChallengeRouter\(\)')) {
    if ($TraceOn) { Write-Host "Inserting app.use(createDailyChallengeRouter()) line..." -ForegroundColor Yellow }

    $insertIndex = -1
    for ($i = 0; $i -lt $serverLines.Length; $i++) {
        if ($serverLines[$i] -match 'app\.use\(') {
            $insertIndex = $i
        }
    }

    $new = @()

    if ($insertIndex -ge 0) {
        for ($i = 0; $i -lt $serverLines.Length; $i++) {
            $new += $serverLines[$i]
            if ($i -eq $insertIndex) {
                $new += $appUseLine
            }
        }
    } else {
        # fallback: after const app = ...
        $insertIndex = -1
        for ($i = 0; $i -lt $serverLines.Length; $i++) {
            if ($serverLines[$i] -match 'const\s+app') {
                $insertIndex = $i
                break
            }
        }

        if ($insertIndex -ge 0) {
            for ($i = 0; $i -lt $serverLines.Length; $i++) {
                $new += $serverLines[$i]
                if ($i -eq $insertIndex) {
                    $new += $appUseLine
                }
            }
        } else {
            # final fallback: append near end
            $new = $serverLines + "" + $appUseLine
        }
    }

    $serverLines = $new
} else {
    Write-Host "app.use(createDailyChallengeRouter()) already exists." -ForegroundColor Yellow
}

Set-Content -Path $serverCjsPath -Value $serverLines -Encoding UTF8
Write-Host ("Updated server.cjs: {0}" -f $serverCjsPath) -ForegroundColor Green

Write-Host ""
Write-Host "[RESULT] Phase 12.1: PASSED (Daily routes wired into server.cjs)" -ForegroundColor Green
exit 0
