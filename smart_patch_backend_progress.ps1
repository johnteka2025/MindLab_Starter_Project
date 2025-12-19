# smart_patch_backend_progress.ps1
# Patches the REAL backend entry file used by scripts in backend\package.json,
# adds /__server_id, /progress (GET/POST), and /progress/reset, with in-memory solved Set.

$root = "C:\Projects\MindLab_Starter_Project"
$backend = Join-Path $root "backend"
$src = Join-Path $backend "src"
$pkgPath = Join-Path $backend "package.json"

if (-not (Test-Path $pkgPath)) { throw "Missing: $pkgPath" }
if (-not (Test-Path $src)) { throw "Missing: $src" }

$pkg = Get-Content $pkgPath -Raw -Encoding UTF8 | ConvertFrom-Json

# Try to detect entry file from scripts (prefer start, then dev)
$scriptText = ""
if ($pkg.scripts.start) { $scriptText = $pkg.scripts.start }
elseif ($pkg.scripts.dev) { $scriptText = $pkg.scripts.dev }

Write-Host "Backend start/dev script:" -ForegroundColor Cyan
Write-Host $scriptText -ForegroundColor Yellow

function Resolve-EntryFromScript([string]$txt) {
  if (-not $txt) { return $null }

  # common patterns: node src/server.cjs, node ./src/server.js, nodemon src/server.js, ts-node src/server.ts
  $patterns = @(
    "(?i)\b(src\\server\.(cjs|js|ts))\b",
    "(?i)\b(\.\\src\\server\.(cjs|js|ts))\b",
    "(?i)\b(src/server\.(cjs|js|ts))\b",
    "(?i)\b(\.\/src\/server\.(cjs|js|ts))\b"
  )

  foreach ($p in $patterns) {
    $m = [regex]::Match($txt, $p)
    if ($m.Success) { return $m.Groups[1].Value }
  }
  return $null
}

$entryRel = Resolve-EntryFromScript $scriptText
$entryCandidates = @()

if ($entryRel) {
  # Normalize slashes
  $entryRel = $entryRel -replace "/", "\"
  $entryRel = $entryRel -replace "^\.\[\\/]", ""  # remove leading ./ or .\
  $entryCandidates += (Join-Path $backend $entryRel)
}

# If not found in scripts, fall back to existing files (prefer server.cjs, then server.js, then server.ts)
if ($entryCandidates.Count -eq 0) {
  $fallback = @(
    (Join-Path $src "server.cjs"),
    (Join-Path $src "server.js"),
    (Join-Path $src "server.ts")
  )
  $entryCandidates += ($fallback | Where-Object { Test-Path $_ })
}

if ($entryCandidates.Count -eq 0) { throw "Could not locate any server entry file in backend\src." }

Write-Host "`nServer entry candidate(s) to patch:" -ForegroundColor Cyan
$entryCandidates | ForEach-Object { Write-Host $_ -ForegroundColor Green }

# Patch function (works for .js/.cjs; for .ts it may work if backend runs ts-node, but can fail if types are strict)
function Patch-ServerFile([string]$path) {
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $bak = "$path.bak_$stamp"
  Copy-Item -Force $path $bak
  Write-Host "Backup created: $bak" -ForegroundColor Green

  $txt = Get-Content -Raw -Encoding UTF8 $path
  $fileId = [IO.Path]::GetFileName($path)

  # Ensure progress Set exists once
  if ($txt -notmatch "__mindlabProgressSolvedIds") {
    $snippet = @"
`n// -----------------------------
 // Progress store (in-memory)
 // -----------------------------
 const __mindlabProgressSolvedIds = new Set(); // puzzleId numbers solved correctly
"@
    $appCreatePattern = "(?im)^\s*(const|let|var)\s+app\s*=\s*express\(\)\s*;\s*$"
    if ([regex]::IsMatch($txt, $appCreatePattern)) {
      $txt = [regex]::Replace($txt, $appCreatePattern, { param($m) $m.Value + $snippet }, 1)
    } else {
      $txt = $snippet + "`n" + $txt
    }
  }

  # Remove any previous injected blocks (idempotent)
  $txt = [regex]::Replace($txt, "(?is)\s*app\.get\(\s*['""]\/__server_id['""]\s*,.*?\)\s*;\s*", "`n")
  $txt = [regex]::Replace($txt, "(?is)\s*app\.post\(\s*['""]\/progress\/reset['""]\s*,.*?\)\s*;\s*", "`n")
  $txt = [regex]::Replace($txt, "(?is)\s*app\.get\(\s*['""]\/progress['""]\s*,.*?\)\s*;\s*", "`n")
  $txt = [regex]::Replace($txt, "(?is)\s*app\.post\(\s*['""]\/progress['""]\s*,.*?\)\s*;\s*", "`n")

  # Insert fresh handlers near end (safe and deterministic)
  $handlers = @"
`n// -----------------------------
 // Server identity (diagnostic)
 // -----------------------------
 app.get('/__server_id', (req, res) => {
   res.json({ serverFile: '$fileId' });
 });

 // -----------------------------
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

 app.post('/progress/reset', (req, res) => {
   __mindlabProgressSolvedIds.clear();
   return res.json({ ok: true });
 });
"@

  $txt = $txt.TrimEnd() + "`n" + $handlers + "`n"

  Set-Content -Path $path -Encoding UTF8 -Value $txt
  Write-Host "Patched: $path" -ForegroundColor Green
}

# Patch ALL candidates (safe). Only the running one will matter.
foreach ($p in ($entryCandidates | Select-Object -Unique)) {
  Patch-ServerFile $p
}

Write-Host "`nNEXT:" -ForegroundColor Cyan
Write-Host "1) Restart backend server (stop/start) so the patched file loads." -ForegroundColor Cyan
Write-Host "2) Run verify_progress_v2.ps1 to confirm which server file is running and that solved increments." -ForegroundColor Cyan
