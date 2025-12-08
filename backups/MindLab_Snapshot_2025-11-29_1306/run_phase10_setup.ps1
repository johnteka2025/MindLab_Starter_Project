param(
    [switch]$TraceOn
)

# MindLab - Phase 10 Setup
# Creates:
#   - frontend/src/daily-challenge/models.ts
#   - docs/daily_challenge_api_contract.md

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Write-Host "=== MindLab Phase 10 - Daily Challenge setup ===" -ForegroundColor Cyan
Write-Host "Project root: $root"
if ($TraceOn) {
    Write-Host "Trace mode: ON" -ForegroundColor Yellow
}

# Paths
$frontendDir = Join-Path $root "frontend"
$docsDir     = Join-Path $root "docs"
$srcDir      = Join-Path $frontendDir "src"
$dailyDir    = Join-Path $srcDir "daily-challenge"

# Sanity checks for folders
if (-not (Test-Path $frontendDir)) {
    Write-Host ("ERROR: Frontend folder not found: {0}" -f $frontendDir) -ForegroundColor Red
    Write-Host "[RESULT] Phase 10: FAILED (missing frontend folder)" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $srcDir   -Force | Out-Null
New-Item -ItemType Directory -Path $dailyDir -Force | Out-Null
New-Item -ItemType Directory -Path $docsDir  -Force | Out-Null

# --------------------------------------------------------------------
# 1) Create frontend models file
# --------------------------------------------------------------------

Write-Host ""
Write-Host "STEP 1 - Creating frontend daily-challenge models.ts" -ForegroundColor Cyan

$modelsPath = Join-Path $dailyDir "models.ts"

$modelsContent = @"
export type DailyChallengeStatusValue =
  | "not_started"
  | "in_progress"
  | "completed";

export type DailyChallengeBand = "A" | "B" | "C"; // A = Explorer, B = Thinker, C = Master

export interface DailyChallengeStatus {
  /** "not_started" | "in_progress" | "completed" */
  status: DailyChallengeStatusValue;
  /** Number of days in a row the user has completed the challenge */
  streakCount: number;
  /** How many puzzles are completed today */
  puzzlesCompletedToday: number;
  /** Total puzzles required for today's challenge */
  totalPuzzlesForToday: number;
  /** Difficulty band label ("A" | "B" | "C") */
  band: DailyChallengeBand;
  /** ISO date string for "today" on the server, e.g. "2025-11-26" */
  challengeDate: string;
}

export interface DailyChallengePuzzleSummary {
  id: string;
  /** Human-readable name or short description of the puzzle */
  title: string;
  /** Puzzle type key, e.g. "logic", "memory", "pattern" */
  type: string;
  /** Optional difficulty level (1-5, etc.) */
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

/**
 * Response shape for GET /daily/status
 */
export interface DailyStatusResponse {
  status: DailyChallengeStatusValue;
  streakCount: number;
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  band: DailyChallengeBand;
  challengeDate: string;
}

/**
 * Response shape for GET /daily
 * This is the "full" instance information for today's challenge.
 */
export interface DailyInstanceResponse extends DailyChallengeInstance {}

/**
 * Response shape for POST /daily/answer
 */
export interface DailyAnswerResponse {
  dailyChallengeId: string;
  puzzleId: string;
  /** true if the answer was considered correct */
  correct: boolean;
  /** Updated number of completed puzzles for today */
  completedCount: number;
  /** total puzzles in the challenge */
  totalPuzzles: number;
  /** Updated overall status ("in_progress" or "completed") */
  status: DailyChallengeStatusValue;
  /** Updated streak count (only increments when the last puzzle is completed) */
  streakCount: number;
}
"@

try {
    Set-Content -Path $modelsPath -Value $modelsContent -Encoding UTF8
    Write-Host ("Created/updated: {0}" -f $modelsPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing models.ts: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 10: FAILED (models.ts write error)" -ForegroundColor Red
    exit 1
}

# --------------------------------------------------------------------
# 2) Create API contract doc
# --------------------------------------------------------------------

Write-Host ""
Write-Host "STEP 2 - Creating docs/daily_challenge_api_contract.md" -ForegroundColor Cyan

$apiDocPath = Join-Path $docsDir "daily_challenge_api_contract.md"

$apiDocContent = @"
# MindLab Daily Challenge API Contract (Phase 10)

## 1. GET /daily/status

Returns a summary of the current day's Daily Challenge for the current user.

### Response 200 OK (JSON)

{
  "status": "not_started" | "in_progress" | "completed",
  "streakCount": number,
  "puzzlesCompletedToday": number,
  "totalPuzzlesForToday": number,
  "band": "A" | "B" | "C",
  "challengeDate": "YYYY-MM-DD"
}

- status:
  - "not_started": user has not begun today's challenge.
  - "in_progress": user has started but not finished.
  - "completed": user has finished all puzzles for today.
- streakCount: number of consecutive days the user has completed the challenge.
- puzzlesCompletedToday / totalPuzzlesForToday: progress numbers.
- band: difficulty band (A=Explorer, B=Thinker, C=Master).
- challengeDate: server-side date for the challenge.

---

## 2. GET /daily

Creates or retrieves today's challenge instance for the current user.

### Response 200 OK (JSON)

{
  "dailyChallengeId": string,
  "band": "A" | "B" | "C",
  "challengeDate": "YYYY-MM-DD",
  "totalPuzzles": number,
  "completedCount": number,
  "status": "not_started" | "in_progress" | "completed",
  "puzzles": [
    {
      "id": string,
      "title": string,
      "type": string,
      "difficulty": number
    }
  ]
}

This object matches the DailyChallengeInstance interface defined in
frontend/src/daily-challenge/models.ts.

---

## 3. GET /daily/puzzles (optional)

Optional convenience endpoint. May be omitted if /daily already returns all puzzles.

### Response 200 OK (JSON)

{
  "dailyChallengeId": string,
  "puzzles": DailyChallengePuzzleSummary[]
}

---

## 4. POST /daily/answer

Submit an answer for a specific puzzle.

### Request body (JSON)

{
  "dailyChallengeId": string,
  "puzzleId": string,
  "answer": any
}

answer payload format depends on the puzzle type and should match
whatever the existing puzzle APIs use.

### Response 200 OK (JSON)

{
  "dailyChallengeId": string,
  "puzzleId": string,
  "correct": boolean,
  "completedCount": number,
  "totalPuzzles": number,
  "status": "in_progress" | "completed",
  "streakCount": number
}

Behavior:

- The backend validates the answer based on the puzzle type.
- If correct, increments completedCount.
- When completedCount === totalPuzzles, set status = "completed" and
  update streakCount if this is the first completion for challengeDate.

---

## 5. Error handling (generic)

On invalid dailyChallengeId or puzzleId, respond with 400 or 404 and
a JSON error object:

{
  "error": "DailyChallengeNotFound" | "PuzzleNotFound" | "ValidationError",
  "message": string
}
"@

try {
    Set-Content -Path $apiDocPath -Value $apiDocContent -Encoding UTF8
    Write-Host ("Created/updated: {0}" -f $apiDocPath) -ForegroundColor Green
}
catch {
    Write-Host ("ERROR writing API contract doc: {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "[RESULT] Phase 10: FAILED (API doc write error)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[RESULT] Phase 10: PASSED (models.ts + API contract created)" -ForegroundColor Green
exit 0
