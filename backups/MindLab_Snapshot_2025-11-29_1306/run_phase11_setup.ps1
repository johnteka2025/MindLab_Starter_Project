param(
    [switch]$TraceOn
)

# MindLab - Phase 11 Setup
# Creates backend core engine for Daily Challenge:
#   backend/src/daily-challenge/dailyChallengeEngine.ts
#
# NOTE: This module is NOT wired into HTTP yet, so it does not change
# existing backend behavior. Safe to add.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 11 - Daily Challenge backend engine ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) { Write-Host "Trace mode: ON" -ForegroundColor Yellow }

# -----------------------
# Folder sanity checks
# -----------------------
$backendDir = Join-Path $root "backend"
if (-not (Test-Path $backendDir)) {
    Write-Host ("ERROR: Backend folder not found: {0}" -f $backendDir) -ForegroundColor Red
    Write-Host "[RESULT] Phase 11: FAILED (missing backend folder)" -ForegroundColor Red
    exit 1
}

$srcDir   = Join-Path $backendDir "src"
$dailyDir = Join-Path $srcDir "daily-challenge"

New-Item -ItemType Directory -Path $srcDir   -Force | Out-Null
New-Item -ItemType Directory -Path $dailyDir -Force | Out-Null

$enginePath = Join-Path $dailyDir "dailyChallengeEngine.ts"

# -----------------------
# Create the engine file
# -----------------------
Write-Host ""
Write-Host "STEP 1 - Creating backend dailyChallengeEngine.ts" -ForegroundColor Cyan

$engineContent = @"
/**
 * Daily Challenge backend core logic (Phase 11).
 * Pure functions only – not yet wired into HTTP routes.
 */

export type DailyChallengeStatusValue =
  | "not_started"
  | "in_progress"
  | "completed";

export type DailyChallengeBand = "A" | "B" | "C"; // A = Explorer, B = Thinker, C = Master

export interface DailyChallengeConfig {
  band: DailyChallengeBand;
  puzzleCount: number;
}

export interface DailyChallengePuzzleSummary {
  id: string;
  title: string;
  type: string;
  difficulty?: number;
}

export interface DailyChallengeInstance {
  dailyChallengeId: string;
  band: DailyChallengeBand;
  challengeDate: string;          
  totalPuzzles: number;
  completedCount: number;
  status: DailyChallengeStatusValue;
  puzzles: DailyChallengePuzzleSummary[];
}

export interface DailyStatus {
  status: DailyChallengeStatusValue;
  streakCount: number;
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  band: DailyChallengeBand;
  challengeDate: string;
}

export interface AnswerResult {
  instance: DailyChallengeInstance;
  correct: boolean;
  streakCount: number;
}

export const BAND_CONFIG: Record<DailyChallengeBand, DailyChallengeConfig> = {
  A: { band: "A", puzzleCount: 3 },
  B: { band: "B", puzzleCount: 4 },
  C: { band: "C", puzzleCount: 5 },
};

export function getTodayKey(date: Date = new Date()): string {
  const y = date.getUTCFullYear();
  const m = (date.getUTCMonth() + 1).toString().padStart(2, "0");
  const d = date.getUTCDate().toString().padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export function generateDailyChallengeId(userKey: string, dateKey: string): string {
  return `${userKey}:${dateKey}`;
}

export function createDailyChallengeInstance(
  userKey: string,
  band: DailyChallengeBand,
  dateKey: string,
  puzzles: DailyChallengePuzzleSummary[]
): DailyChallengeInstance {
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

export function deriveStatus(
  instance: DailyChallengeInstance,
  streakCount: number
): DailyStatus {
  return {
    status: instance.status,
    streakCount,
    puzzlesCompletedToday: instance.completedCount,
    totalPuzzlesForToday: instance.totalPuzzles,
    band: instance.band,
    challengeDate: instance.challengeDate,
  };
}

export function applyAnswer(
  instance: DailyChallengeInstance,
  puzzleId: string,
  correct: boolean,
  currentStreakCount: number
): AnswerResult {
  const updated: DailyChallengeInstance = {
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

  if (updated.completedCount >= updated.totalPuzzles && updated.totalPuzzles > 0) {
    updated.status = "completed";
  } else if (updated.completedCount > 0) {
    updated.status = "in_progress";
  } else {
    updated.status = "not_started";
  }

  let newStreak = currentStreakCount;

  if (
    instance.status !== "completed" &&
    updated.status === "completed"
  ) {
    newStreak = currentStreakCount + 1;
  }

  return {
    instance: updated,
    correct,
    streakCount: newStreak,
  };
}  // We will insert full TS engine next (see next message)
"@

try {
    Set-Content -Path $enginePath -Value $engineContent -Encoding UTF8
    Write-Host ("Created/updated: {0}" -f $enginePath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing dailyChallengeEngine.ts: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 11: FAILED (engine write error)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Phase 11: PASSED (backend engine created)" -ForegroundColor Green
exit 0

