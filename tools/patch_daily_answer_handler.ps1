@'
param(
  [Parameter(Mandatory=$false)]
  [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; exit 1 }
function Ok([string]$msg)   { Write-Host "OK: $msg" -ForegroundColor Green }

function WriteUtf8NoBom([string]$path, [string]$content) {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}

function MatchCount([string]$text, [string]$regexPattern) {
  return [regex]::Matches($text, $regexPattern).Count
}

Push-Location $RepoRoot
try {
  if (!(Test-Path $RepoRoot)) { Fail "Repo root not found: $RepoRoot" }

  $target = Join-Path $RepoRoot "backend\src\daily-challenge\dailyChallengeRoutes.ts"
  if (!(Test-Path $target)) { Fail "Target file not found: $target" }

  $routeRegex = 'router\.post\(\"\/daily\/answer\"'

  # Always force Select-String into an array to make counting safe
  $routeMatches = @(Select-String -Path $target -Pattern $routeRegex)
  $preCount = $routeMatches.Length
  if ($preCount -ne 1) { Fail "Expected exactly 1 /daily/answer route BEFORE patch, found $preCount" }
  Ok "Found exactly 1 /daily/answer route BEFORE patch"

  # Backup
  $bak = Join-Path $env:TEMP ("dailyChallengeRoutes.ts.beforePatch_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
  Copy-Item $target $bak -Force
  if (!(Test-Path $bak)) { Fail "Backup failed: $bak" }
  Ok "Backup created: $bak"

  # Load file
  $content = Get-Content -Path $target -Raw -Encoding UTF8
  $content = $content -replace "`r`n","`n"

  $token = 'router.post("/daily/answer"'
  $startIdx = $content.IndexOf($token)
  if ($startIdx -lt 0) { Fail "Could not find token: $token" }

  $openBraceIdx = $content.IndexOf("{", $startIdx)
  if ($openBraceIdx -lt 0) { Fail "Could not find opening brace for /daily/answer route block" }

  # Brace-count scan to end of route, then close on ');'
  $depth = 0
  $inString = $false
  $stringChar = ''
  $escape = $false
  $endIdx = -1

  for ($i = $openBraceIdx; $i -lt $content.Length; $i++) {
    $ch = $content[$i]

    if ($escape) { $escape = $false; continue }
    if ($ch -eq "\") { $escape = $true; continue }

    if ($inString) {
      if ($ch -eq $stringChar) { $inString = $false; $stringChar = '' }
      continue
    } else {
      if ($ch -eq '"' -or $ch -eq "'") { $inString = $true; $stringChar = $ch; continue }
      if ($ch -eq "{") { $depth++; continue }
      if ($ch -eq "}") {
        $depth--
        if ($depth -eq 0) {
          $closeParen = $content.IndexOf(");", $i)
          if ($closeParen -lt 0) { Fail "Could not find closing ');' after route block" }
          $endIdx = $closeParen + 2
          break
        }
      }
    }
  }

  if ($endIdx -lt 0) { Fail "Failed to determine end of /daily/answer route block" }

  $replacement = @'
  // POST /daily/answer
  router.post("/daily/answer", (req: Request, res: Response) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(userKey, band, dateKey);

    const body: any = req.body ?? {};

    // 1) missing puzzleId -> 400
    const puzzleIdRaw = body.puzzleId;
    if (puzzleIdRaw === undefined || puzzleIdRaw === null) {
      return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });
    }
    const puzzleId = String(puzzleIdRaw);

    // 2) challenge completed -> 409
    if (instance.status === "completed" || instance.completedCount >= instance.totalPuzzles) {
      return res.status(409).json({ error: "ChallengeCompleted", message: "daily challenge already completed" });
    }

    // 3) puzzleId not in today's puzzles -> 404
    const hasPuzzle =
      Array.isArray(instance.puzzles) &&
      instance.puzzles.some((p: any) => String(p.id) === puzzleId);
    if (!hasPuzzle) {
      return res.status(404).json({ error: "PuzzleNotFound", message: "puzzleId not found in today's puzzles" });
    }

    // 4) already answered -> 409
    if (!state.answeredByDate[dateKey]) state.answeredByDate[dateKey] = {};
    if (state.answeredByDate[dateKey][puzzleId]) {
      return res.status(409).json({ error: "PuzzleAlreadyAnswered", message: "puzzle already answered" });
    }

    // Accept answer -> 200 (demo: treat as correct)
    const correct = true;
    const result = applyAnswer(instance, puzzleId, correct, state.streakCount);

    state.instanceByDate[dateKey] = result.instance;
    state.streakCount = result.streakCount;
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

  $before = $content.Substring(0, $startIdx)
  $after  = $content.Substring($endIdx)
  $newContent = $before + $replacement + $after

  $postCount = MatchCount $newContent $routeRegex
  if ($postCount -ne 1) { Fail "Post-patch sanity failed: expected 1 /daily/answer route AFTER patch, found $postCount" }
  Ok "Confirmed exactly 1 /daily/answer route AFTER patch"

  WriteUtf8NoBom $target $newContent
  Ok "Patched file written successfully"
  Ok "Backup at: $bak"

 catch {
  Fail $_.Exception.Message
} finally {
  Pop-Location
}
'@ | Set-Content -Path $Patch -Encoding UTF8'
