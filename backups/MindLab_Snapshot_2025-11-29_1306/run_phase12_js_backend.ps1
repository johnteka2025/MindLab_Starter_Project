param(
    [switch]$TraceOn
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 12 (JS) - Daily Challenge backend wiring ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) { Write-Host "Trace mode: ON" -ForegroundColor Yellow }

# -----------------------
# Folder sanity checks
# -----------------------
$backendDir = Join-Path $root "backend"
if (-not (Test-Path $backendDir)) {
    Write-Host ("ERROR: Backend folder not found: {0}" -f $backendDir) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12 JS: FAILED (missing backend folder)" -ForegroundColor Red
    exit 1
}

$srcDir   = Join-Path $backendDir "src"
$dailyDir = Join-Path $srcDir "daily-challenge"

New-Item -ItemType Directory -Path $srcDir   -Force | Out-Null
New-Item -ItemType Directory -Path $dailyDir -Force | Out-Null

$engineJsPath  = Join-Path $dailyDir "dailyChallengeEngine.cjs"
$routesJsPath  = Join-Path $dailyDir "dailyChallengeRoutes.cjs"
$serverCjsPath = Join-Path $srcDir  "server.cjs"

if (-not (Test-Path $serverCjsPath)) {
    Write-Host ("ERROR: server.cjs not found at: {0}" -f $serverCjsPath) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12 JS: FAILED (missing server.cjs)" -ForegroundColor Red
    exit 1
}

# -----------------------
# STEP 1 - JS engine file
# -----------------------
Write-Host ""
Write-Host "STEP 1 - Creating JS engine: dailyChallengeEngine.cjs" -ForegroundColor Cyan

$engineJsContent = @"
/**
 * Daily Challenge backend core logic (CommonJS version).
 * This mirrors the TypeScript engine but runs directly in Node.
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

try {
    Set-Content -Path $engineJsPath -Value $engineJsContent -Encoding UTF8
    Write-Host ("Created/updated: {0}" -f $engineJsPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing engine JS file: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12 JS: FAILED (engine write error)" -ForegroundColor Red
    exit 1
}

# -----------------------
# STEP 2 - JS routes file
# -----------------------
Write-Host ""
Write-Host "STEP 2 - Creating JS routes: dailyChallengeRoutes.cjs" -ForegroundColor Cyan

$routesJsContent = @"
const express = require("express");
const {
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
} = require("./dailyChallengeEngine.cjs");

/**
 * In-memory store for Daily Challenge state.
 * For production, replace with database storage.
 */

// userKey -> { instanceByDate: { [dateKey]: instance }, streakCount: number }
const userStore = {};

function getUserKey(req) {
  // Later this can come from auth/session.
  return "demo-user";
}

function getBandForUser(req) {
  // Later this could be user preference or difficulty level.
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

    // state currently unused here, but kept for symmetry.
    void state;

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

    // For now, treat all answers as correct.
    const correct = true;

    const result = applyAnswer(
      instance,
      puzzleId,
      correct,
      state.streakCount
    );

    // Save updated instance & streak
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

try {
    Set-Content -Path $routesJsPath -Value $routesJsContent -Encoding UTF8
    Write-Host ("Created/updated: {0}" -f $routesJsPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing routes JS file: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12 JS: FAILED (routes write error)" -ForegroundColor Red
    exit 1
}

# -----------------------
# STEP 3 - Wire into server.cjs
# -----------------------
Write-Host ""
Write-Host "STEP 3 - Wiring router into server.cjs" -ForegroundColor Cyan

$serverContent = Get-Content $serverCjsPath -Raw

$requireLine = 'const { createDailyChallengeRouter } = require("./daily-challenge/dailyChallengeRoutes.cjs");'
$appUseLine  = 'app.use(createDailyChallengeRouter());'

if ($serverContent -notmatch [regex]::Escape('createDailyChallengeRouter')) {
    Write-Host "Adding require(...) for createDailyChallengeRouter..." -ForegroundColor Cyan

    $lines = $serverContent -split "(`r`n|`n|`r)"
    $importIndices = @()

    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^\s*const\s+.*=\s*require\(') {
            $importIndices += $i
        }
    }

    if ($importIndices.Count -eq 0) {
        $newLines = @($requireLine) + "" + $lines
    } else {
        $lastImportIndex = $importIndices[-1]
        $newLines = @()
        for ($i = 0; $i -lt $lines.Length; $i++) {
            $newLines += $lines[$i]
            if ($i -eq $lastImportIndex) {
                $newLines += $requireLine
            }
        }
    }

    $serverContent = ($newLines -join "`r`n")
} else {
    Write-Host "Require for createDailyChallengeRouter already present." -ForegroundColor Yellow
}

if ($serverContent -notmatch [regex]::Escape($appUseLine)) {
    Write-Host "Adding app.use(createDailyChallengeRouter())..." -ForegroundColor Cyan

    $lines = $serverContent -split "(`r`n|`n|`r)"

    $insertIndex = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match 'app\.use\(\s*express\.json\(\)\s*\)') {
            $insertIndex = $i
        }
    }

    if ($insertIndex -ge 0) {
        $newLines = @()
        for ($i = 0; $i -lt $lines.Length; $i++) {
            $newLines += $lines[$i]
            if ($i -eq $insertIndex) {
                $newLines += $appUseLine
            }
        }
    } else {
        $insertIndex = -1
        for ($i = 0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match 'const\s+app\s*=\s*express\(\)\s*;') {
                $insertIndex = $i
                break
            }
        }

        if ($insertIndex -ge 0) {
            $newLines = @()
            for ($i = 0; $i -lt $lines.Length; $i++) {
                $newLines += $lines[$i]
                if ($i -eq $insertIndex) {
                    $newLines += $appUseLine
                }
            }
        } else {
            Write-Host "ERROR: Could not find 'app.use(express.json())' or 'const app = express();' in server.cjs." -ForegroundColor Red
            Write-Host "[RESULT] Phase 12 JS: FAILED (no insertion point in server.cjs)" -ForegroundColor Red
            exit 1
        }
    }

    $serverContent = ($newLines -join "`r`n")
} else {
    Write-Host "app.use(createDailyChallengeRouter()) already present." -ForegroundColor Yellow
}

try {
    Set-Content -Path $serverCjsPath -Value $serverContent -Encoding UTF8
    Write-Host ("Updated server.cjs: {0}" -f $serverCjsPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing server.cjs: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12 JS: FAILED (server write error)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Phase 12 JS: PASSED (JS engine + routes wired into server.cjs)" -ForegroundColor Green
exit 0
