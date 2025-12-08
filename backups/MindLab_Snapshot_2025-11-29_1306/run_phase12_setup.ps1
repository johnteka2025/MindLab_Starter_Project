param(
    [switch]$TraceOn
)

# MindLab - Phase 12 Setup
# Creates backend Daily Challenge HTTP routes:
#   backend/src/daily-challenge/dailyChallengeRoutes.ts
#
# NOTE: This file is NOT automatically registered with Express.
# You will add a small import + app.use(...) in your main server file
# after this script runs.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 12 - Daily Challenge HTTP API ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) { Write-Host "Trace mode: ON" -ForegroundColor Yellow }

# -----------------------
# Folder sanity checks
# -----------------------
$backendDir = Join-Path $root "backend"
if (-not (Test-Path $backendDir)) {
    Write-Host ("ERROR: Backend folder not found: {0}" -f $backendDir) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12: FAILED (missing backend folder)" -ForegroundColor Red
    exit 1
}

$srcDir   = Join-Path $backendDir "src"
$dailyDir = Join-Path $srcDir "daily-challenge"

New-Item -ItemType Directory -Path $srcDir   -Force | Out-Null
New-Item -ItemType Directory -Path $dailyDir -Force | Out-Null

$routesPath = Join-Path $dailyDir "dailyChallengeRoutes.ts"

# -----------------------
# Create the routes file
# -----------------------
Write-Host ""
Write-Host "STEP 1 - Creating backend dailyChallengeRoutes.ts" -ForegroundColor Cyan

$routesContent = @"
import { Router, Request, Response } from "express";
import {
  DailyChallengeInstance,
  DailyChallengePuzzleSummary,
  DailyChallengeBand,
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
} from "./dailyChallengeEngine";

/**
 * Simple in-memory store for Daily Challenge state.
 * For real production use, replace this with persistent storage.
 */

type DailyChallengeState = {
  instanceByDate: Record<string, DailyChallengeInstance>;
  streakCount: number;
};

const userStore: Record<string, DailyChallengeState> = {};

/**
 * Derive a user key from the request.
 * For now we just return a fixed key. If you have auth, replace with
 * something like req.user.id or a session identifier.
 */
function getUserKey(req: Request): string {
  return "demo-user";
}

/**
 * Determine the band for the user.
 * For now this returns "B" (Thinker) by default.
 * Later you can use a profile setting, age, or difficulty preference.
 */
function getBandForUser(req: Request): DailyChallengeBand {
  return "B";
}

function getOrCreateUserState(userKey: string): DailyChallengeState {
  let state = userStore[userKey];
  if (!state) {
    state = {
      instanceByDate: {},
      streakCount: 0,
    };
    userStore[userKey] = state;
  }
  return state;
}

function generatePuzzlesForBand(
  band: DailyChallengeBand,
  dateKey: string
): DailyChallengePuzzleSummary[] {
  const config = BAND_CONFIG[band];
  const puzzles: DailyChallengePuzzleSummary[] = [];
  const count = config.puzzleCount;

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

function getOrCreateInstanceForToday(
  userKey: string,
  band: DailyChallengeBand,
  dateKey: string
): { state: DailyChallengeState; instance: DailyChallengeInstance } {
  const state = getOrCreateUserState(userKey);
  let instance = state.instanceByDate[dateKey];

  if (!instance) {
    const puzzles = generatePuzzlesForBand(band, dateKey);
    instance = createDailyChallengeInstance(userKey, band, dateKey, puzzles);
    state.instanceByDate[dateKey] = instance;
  }

  return { state, instance };
}

/**
 * Create an Express router with:
 *  - GET /daily/status
 *  - GET /daily
 *  - POST /daily/answer
 */
export function createDailyChallengeRouter(): Router {
  const router = Router();

  // GET /daily/status
  router.get("/daily/status", (req: Request, res: Response) => {
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
  router.get("/daily", (req: Request, res: Response) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    // state is unused here, but we keep it for symmetry and future use.
    void state;

    return res.status(200).json(instance);
  });

  // POST /daily/answer
  router.post("/daily/answer", (req: Request, res: Response) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    const body: any = req.body ?? {};
    const dailyChallengeId: string | undefined = body.dailyChallengeId;
    const puzzleId: string | undefined = body.puzzleId;
    // const answer = body.answer; // Not used in this placeholder implementation

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

    // In this first implementation, we treat all answers as correct=true.
    // Later you can validate based on puzzle type + answer payload.
    const correct = true;

    const result = applyAnswer(
      instance,
      puzzleId,
      correct,
      state.streakCount
    );

    // Persist updated instance + streak in the in-memory store
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
"@

try {
    Set-Content -Path $routesPath -Value $routesContent -Encoding UTF8
    Write-Host ("Created/updated: {0}" -f $routesPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing dailyChallengeRoutes.ts: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 12: FAILED (routes write error)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Phase 12: PASSED (routes file created)" -ForegroundColor Green
exit 0
