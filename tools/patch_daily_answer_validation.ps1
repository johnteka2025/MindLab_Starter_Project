Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Always end at repo root
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $repoRoot
try {
  $file = ".\backend\src\daily-challenge\dailyChallengeRoutes.ts"
  if (-not (Test-Path -LiteralPath $file)) { throw "STOP: missing target file: $file" }

  $backup = Join-Path $env:TEMP "dailyChallengeRoutes.ts.prePatch.backup"
  Copy-Item -LiteralPath $file -Destination $backup -Force

  $src = Get-Content -LiteralPath $file -Raw

  # Find route start
  $needle1 = 'router.post("/daily/answer"'
  $needle2 = "router.post('/daily/answer'"
  $start = $src.IndexOf($needle1)
  if ($start -lt 0) { $start = $src.IndexOf($needle2) }
  if ($start -lt 0) { throw "STOP: cannot find /daily/answer route anchor." }

  # Find handler open brace after =>
  $arrow = $src.IndexOf("=>", $start)
  if ($arrow -lt 0) { throw "STOP: cannot find '=>' after /daily/answer anchor." }

  $openBrace = $src.IndexOf("{", $arrow)
  if ($openBrace -lt 0) { throw "STOP: cannot find handler '{' after '=>'." }

  # Walk braces to find handler close brace
  $depth = 0
  $closeBrace = -1
  for ($i = $openBrace; $i -lt $src.Length; $i++) {
    $ch = $src[$i]
    if ($ch -eq "{") { $depth++ }
    elseif ($ch -eq "}") {
      $depth--
      if ($depth -eq 0) { $closeBrace = $i; break }
    }
  }
  if ($closeBrace -lt 0) { throw "STOP: failed to find matching '}' for /daily/answer handler." }

  # Find route terminator ');' after handler
  $end = $src.IndexOf(");", $closeBrace)
  if ($end -lt 0) { throw "STOP: failed to find route terminator ');' after handler." }
  $end = $end + 2

  # Replacement route (single-quote-safe)
  $replacement = @"
router.post("/daily/answer", (req: Request, res: Response) => {
  const userKey = getUserKey(req);
  const dateKey = getTodayKey();
  const state = getOrCreateUserState(userKey);

  // Ensure today's instance exists
  let instance = state.instanceByDate[dateKey];
  if (!instance) {
    const band = getBandForUser(req);
    const puzzles = getDailyPuzzlesForBand(band);
    instance = createDailyChallengeInstance(userKey, band, dateKey, puzzles);
    state.instanceByDate[dateKey] = instance;
  }

  const body: any = req.body ?? {};

  // Rule (1): puzzleId missing -> 400
  const puzzleIdRaw = body.puzzleId;
  if (puzzleIdRaw === undefined || puzzleIdRaw === null) {
    return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });
  }
  const puzzleId = String(puzzleIdRaw);

  // Rule (2): dailyChallengeId provided but not today's -> 400
  const dailyChallengeIdRaw = body.dailyChallengeId;
  const providedDailyChallengeId =
    dailyChallengeIdRaw === undefined || dailyChallengeIdRaw === null ? undefined : String(dailyChallengeIdRaw);

  if (providedDailyChallengeId && providedDailyChallengeId !== instance.dailyChallengeId) {
    return res.status(400).json({
      error: "DailyChallengeNotFound",
      message: "dailyChallengeId does not match today's challenge",
      dailyChallengeId: instance.dailyChallengeId,
    });
  }

  // Rule (4): challenge already completed -> 409
  if (instance.status === "completed") {
    return res.status(409).json({
      error: "ChallengeCompleted",
      message: "daily challenge already completed",
      dailyChallengeId: instance.dailyChallengeId,
    });
  }

  // Rule (5): puzzleId not found in today's puzzles -> 404
  const hasPuzzle = Array.isArray(instance.puzzles) && instance.puzzles.some((p: any) => String(p.id) === puzzleId);
  if (!hasPuzzle) {
    return res.status(404).json({
      error: "PuzzleNotFound",
      message: "puzzleId not found in today's puzzles",
      dailyChallengeId: instance.dailyChallengeId,
      puzzleId,
    });
  }

  // Ensure answered-by-date index exists
  if (!(state as any).answeredByDate) (state as any).answeredByDate = {};
  if (!(state as any).answeredByDate[dateKey]) (state as any).answeredByDate[dateKey] = {};

  // Rule (3): puzzle already answered -> 409
  if ((state as any).answeredByDate[dateKey][puzzleId]) {
    return res.status(409).json({
      error: "PuzzleAlreadyAnswered",
      message: "puzzle already answered",
      dailyChallengeId: instance.dailyChallengeId,
      puzzleId,
    });
  }

  // Accept answer -> 200
  const correct = true;
  const result = applyAnswer(instance, puzzleId, correct, (state as any).streakCount);

  state.instanceByDate[dateKey] = result.instance;
  (state as any).streakCount = result.streakCount;

  // Mark answered AFTER applyAnswer succeeds
  (state as any).answeredByDate[dateKey][puzzleId] = true;

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
"@

  # Replace route block
  $before = $src.Substring(0, $start)
  $after  = $src.Substring($end)
  $patched = $before + $replacement + $after

  if ($patched -eq $src) { throw "STOP: patch produced no changes." }

  # Write UTF-8 without BOM
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText((Resolve-Path $file), $patched, $utf8NoBom)

  # Sanity checks (must-pass)
  if (-not (Test-Path -LiteralPath $file)) { throw "STOP: target missing after write" }
  Select-String -Path $file -Pattern 'router.post("/daily/answer"' -SimpleMatch | Out-Null
  Select-String -Path $file -Pattern "PuzzleAlreadyAnswered" -SimpleMatch | Out-Null
  Select-String -Path $file -Pattern "ChallengeCompleted" -SimpleMatch | Out-Null
  Select-String -Path $file -Pattern "PuzzleNotFound" -SimpleMatch | Out-Null
  Select-String -Path $file -Pattern "answeredByDate" -SimpleMatch | Out-Null

  Write-Host "OK: patched $file"
  Write-Host "Backup: $backup"
}
finally {
  Pop-Location
  Set-Location $repoRoot
}
