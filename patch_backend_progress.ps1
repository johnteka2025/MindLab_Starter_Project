# patch_backend_progress.ps1
# Goal: Make /progress actually increment solved when correct:true is posted.
# Method: Patch backend\src\server.js in-place (backup first).
# Requirements: Works even if file already has /progress handlers (replaces them).

$serverPath = "C:\Projects\MindLab_Starter_Project\backend\src\server.js"
if (-not (Test-Path $serverPath)) { throw "Missing: $serverPath" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$serverPath.bak_$stamp"
Copy-Item -Force $serverPath $backup
Write-Host "Backup created: $backup" -ForegroundColor Green

$txt = Get-Content -Raw -Encoding UTF8 $serverPath

# Helper: Ensure we have a PORT symbol to call our own /puzzles endpoint.
# We'll not force a PORT declaration; instead we use process.env.PORT || 8085 at runtime in our inserted code.

# Insert a progress store (Set) near the top, after express app creation if possible.
# We'll try to insert after a line like: const app = express(); OR var app = express();
$progressStoreSnippet = @"
`n// -----------------------------
 // Progress store (in-memory)
 // -----------------------------
 const __mindlabProgressSolvedIds = new Set(); // puzzleId numbers solved correctly
"@

if ($txt -notmatch "__mindlabProgressSolvedIds") {
  $appCreatePattern = "(?im)^\s*(const|let|var)\s+app\s*=\s*express\(\)\s*;\s*$"
  if ([regex]::IsMatch($txt, $appCreatePattern)) {
    $txt = [regex]::Replace($txt, $appCreatePattern, { param($m) $m.Value + $progressStoreSnippet }, 1)
  } else {
    # Fallback: put it near the top of file
    $txt = $progressStoreSnippet + "`n" + $txt
  }
}

# Define the new /progress handlers (GET + POST).
# total is computed by calling our own /puzzles endpoint to avoid guessing schema/source.
$progressHandlers = @"
`n// -----------------------------
 // Progress endpoints
 // -----------------------------
 app.get('/progress', async (req, res) => {
   try {
     const port = process.env.PORT || 8085;
     let puzzles = [];
     try {
       const r = await fetch(`http://localhost:${port}/puzzles`);
       if (r.ok) puzzles = await r.json();
     } catch (e) { /* ignore */ }

     const total = Array.isArray(puzzles) ? puzzles.length : 0;
     const solved = __mindlabProgressSolvedIds.size;
     return res.json({ total, solved });
   } catch (err) {
     return res.status(500).json({ error: 'progress_get_failed' });
   }
 });

 app.post('/progress', async (req, res) => {
   try {
     const puzzleIdRaw = req.body && req.body.puzzleId;
     const correctRaw  = req.body && req.body.correct;

     const puzzleId = Number(puzzleIdRaw);
     const correct = (correctRaw === true);

     // Only count correct submissions with a valid numeric puzzleId
     if (Number.isFinite(puzzleId) && correct) {
       __mindlabProgressSolvedIds.add(puzzleId);
     }

     const port = process.env.PORT || 8085;
     let puzzles = [];
     try {
       const r = await fetch(`http://localhost:${port}/puzzles`);
       if (r.ok) puzzles = await r.json();
     } catch (e) { /* ignore */ }

     const total = Array.isArray(puzzles) ? puzzles.length : 0;
     const solved = __mindlabProgressSolvedIds.size;

     return res.json({ total, solved });
   } catch (err) {
     return res.status(500).json({ error: 'progress_post_failed' });
   }
 });

 // Optional reset endpoint for local dev/testing
 app.post('/progress/reset', (req, res) => {
   __mindlabProgressSolvedIds.clear();
   return res.json({ ok: true });
 });
"@

# Replace existing GET /progress handler if found
# Match: app.get('/progress', ... );
$getPattern = "(?is)app\.get\(\s*['""]\/progress['""]\s*,\s*.*?\)\s*;\s*"
if ([regex]::IsMatch($txt, $getPattern)) {
  $txt = [regex]::Replace($txt, $getPattern, "", 1)
}

# Replace existing POST /progress handler if found
$postPattern = "(?is)app\.post\(\s*['""]\/progress['""]\s*,\s*.*?\)\s*;\s*"
if ([regex]::IsMatch($txt, $postPattern)) {
  $txt = [regex]::Replace($txt, $postPattern, "", 1)
}

# Replace existing POST /progress/reset if found
$resetPattern = "(?is)app\.post\(\s*['""]\/progress\/reset['""]\s*,\s*.*?\)\s*;\s*"
if ([regex]::IsMatch($txt, $resetPattern)) {
  $txt = [regex]::Replace($txt, $resetPattern, "", 1)
}

# Insert our handlers near other routes.
# Prefer inserting after the /puzzles route if present; otherwise append near end.
$puzzlesRoutePattern = "(?is)(app\.get\(\s*['""]\/puzzles['""]\s*,\s*.*?\)\s*;\s*)"
if ([regex]::IsMatch($txt, $puzzlesRoutePattern)) {
  $txt = [regex]::Replace($txt, $puzzlesRoutePattern, "`$1$progressHandlers", 1)
} else {
  $txt = $txt + "`n" + $progressHandlers + "`n"
}

Set-Content -Path $serverPath -Encoding UTF8 -Value $txt
Write-Host "Patched: $serverPath" -ForegroundColor Green

Write-Host "`nNEXT:" -ForegroundColor Cyan
Write-Host "1) Restart backend server (stop/start) so new progress logic loads." -ForegroundColor Cyan
Write-Host "2) Run verify_progress.ps1 (we'll create it next) to confirm solved increments." -ForegroundColor Cyan
