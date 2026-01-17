cd "C:\Projects\MindLab_Starter_Project"
New-Item -ItemType Directory -Force ".\tools" | Out-Null

@'
$ErrorActionPreference = "Stop"

$repoRoot = "C:\Projects\MindLab_Starter_Project"
Set-Location $repoRoot

$file = ".\backend\src\daily-challenge\dailyChallengeRoutes.ts"
if (-not (Test-Path $file)) { throw "STOP: target file not found: $file" }

# Backup (local + temp)
Copy-Item $file "$env:TEMP\dailyChallengeRoutes.ts.prePatch.backup" -Force

$src = Get-Content $file -Raw

# --- 1) Ensure DailyChallengeState has answeredByDate ---
# Replace the DailyChallengeState block if it matches the simple shape
$statePattern = 'type\s+DailyChallengeState\s*=\s*\{\s*instanceByDate:\s*Record<string,\s*DailyChallengeInstance>;\s*streakCount:\s*number;\s*\};'
$stateReplacement = @'
type DailyChallengeState = {
  instanceByDate: Record<string, DailyChallengeInstance>;
  streakCount: number;

  // Tracks whether a puzzleId was already answered for a given UTC dateKey.
  answeredByDate: Record<string, Record<string, true>>;
};
'@

$src2 = [regex]::Replace($src, $statePattern, $stateReplacement, "Singleline")
if ($src2 -eq $src) {
  # If the exact simple pattern doesn't match, do a safer insertion if answeredByDate is missing
  if ($src -notmatch 'answeredByDate') {
    $insertPattern = 'type\s+DailyChallengeState\s*=\s*\{'
    if ($src -notmatch $insertPattern) { throw "STOP: Could not locate DailyChallengeState type block." }
    $src2 = [regex]::Replace($src, $insertPattern, 'type DailyChallengeState = {', 1)
    # Insert property after opening brace
    $src2 = [regex]::Replace(
      $src2,
      '(type\s+DailyChallengeState\s*=\s*\{\s*)',
      "`$1`r`n  instanceByDate: Record<string, DailyChallengeInstance>;`r`n  streakCount: number;`r`n`r`n  // Tracks whether a puzzleId was already answered for a given UTC dateKey.`r`n  answeredByDate: Record<string, Record<string, true>>;`r`n",
      1,
      [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    # Remove duplicated original fields if we just inserted (guard: keep if already present)
    $src2 = [regex]::Replace($src2, '(\r?\n)\s*instanceByDate:\s*Record<string,\s*DailyChallengeInstance>;\s*(\r?\n)\s*streakCount:\s*number;\s*(\r?\n)\s*\};', "`$1};", "Singleline")
  } else {
    $src2 = $src
  }
}

# --- 2) Ensure getOrCreateUserState initializes answeredByDate ---
if ($src2 -match 'answeredByDate') {
  # If initialization doesn't exist, add it in the state object literal
  if ($src2 -notmatch 'answeredByDate:\s*\{\s*\}') {
    $src2 = [regex]::Replace(
      $src2,
      '(state\s*=\s*\{\s*[\s\S]*?instanceByDate:\s*\{\s*\},\s*[\s\S]*?streakCount:\s*0,?)',
      "`$1`r`n      answeredByDate: {},",
      1
    )
  }
}

# --- 3) Patch ONLY the /daily/answer route with required rules ---
# Find the /daily/answer handler block
$answerBlockPattern = 'router\.post\("\/daily\/answer"\s*,\s*\(req:\s*Request,\s*res:\s*Response\)\s*=>\s*\{[\s\S]*?\}\);'
if ($src2 -notmatch $answerBlockPattern) { throw "STOP: /daily/answer route block not found (layout changed)." }

$answerReplacement = @'
router.post("/daily/answer", (req: Request, res: Response) => {
  const userKey = getUserKey(req);
  const band = getBandForUser(req);
  const dateKey = getTodayKey();

  const { state, instance } = getOrCreateInstanceForToday(userKey, band, dateKey);

  const body: any = req.body ?? {};
  const dailyChallengeId: string | undefined = body.dailyChallengeId;
  const puzzleId: string | undefined = body.puzzleId;

  // Rule (1): puzzleId missing -> 400
  if (!puzzleId) {
    return res.status(400).json({
      error: "ValidationError",
      message: "puzzleId is required",
    });
  }

  // Rule (2): dailyChallengeId provided but does not match today -> 400
  if (dailyChallengeId && dailyChallengeId !== instance.dailyChallengeId) {
    return res.status(400).json({
      error: "DailyChallengeNotFound",
      message: "dailyChallengeId does not match today's challenge",
    });
  }

  // Rule (4): challenge already completed -> 409
  if (instance.status === "completed") {
    return res.status(409).json({
      error: "DailyChallengeCompleted",
      message: "daily challenge already completed",
    });
  }

  // Rule (5): puzzleId not in today's puzzles -> 404
  const puzzleExists = Array.isArray(instance.puzzles) && instance.puzzles.some((p: any) => p && p.id === puzzleId);
  if (!puzzleExists) {
    return res.status(404).json({
      error: "PuzzleNotFound",
      message: "puzzleId not found in today's puzzles",
    });
  }

  // Rule (3): puzzle already answered -> 409
  state.answeredByDate = state.answeredByDate ?? {};
  state.answeredByDate[dateKey] = state.answeredByDate[dateKey] ?? {};
  if (state.answeredByDate[dateKey][puzzleId]) {
    return res.status(409).json({
      error: "PuzzleAlreadyAnswered",
      message: "puzzle already answered",
    });
  }

  // Accept answer -> 200 (placeholder correctness)
  const correct = true;

  const result = applyAnswer(instance, puzzleId, correct, state.streakCount);

  // Persist updated instance + streak in the in-memory store
  state.instanceByDate[dateKey] = result.instance;
  state.streakCount = result.streakCount;

  // Mark puzzle as answered (enforces Rule 3 on subsequent calls)
  state.answeredByDate[dateKey][puzzleId] = true;

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
'@

$src3 = [regex]::Replace($src2, $answerBlockPattern, $answerReplacement, 1)

# --- Write UTF8 no BOM (PowerShell-safe; no -Encoding required) ---
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Resolve-Path $file), $src3, $utf8NoBom)

# Sanity checks
if (-not (Test-Path $file)) { throw "STOP: write failed; file missing after patch" }
Select-String -Path $file -Pattern 'router\.post\("\/daily\/answer"' -SimpleMatch | Out-Null

Write-Host "OK: patched $file"
Write-Host "Backup: $env:TEMP\dailyChallengeRoutes.ts.prePatch.backup"
'@ | Set-Content -NoNewline -Path ".\tools\patch_daily_answer_validation.ps1"
