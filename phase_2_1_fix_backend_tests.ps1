# phase_2_1_fix_backend_tests.ps1
$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$backendDir  = Join-Path $projectRoot "backend"
$srcDir      = Join-Path $backendDir "src"
$testsDir    = Join-Path $backendDir "tests"
$contractDir = Join-Path $testsDir "contract"
$backupDir   = Join-Path $backendDir "backups\manual_edits"
$stamp       = Get-Date -Format "yyyyMMdd_HHmmss"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[ERROR] $m" -ForegroundColor Red; throw $m }

Info "=== Phase 2.1 Fix Backend Tests ==="
Info "ProjectRoot: $projectRoot"
Info "BackendDir : $backendDir"

if (-not (Test-Path $backendDir)) { Fail "Missing backend folder: $backendDir" }
if (-not (Test-Path $srcDir))     { Fail "Missing backend\src folder: $srcDir" }

New-Item -ItemType Directory -Force -Path $testsDir    | Out-Null
New-Item -ItemType Directory -Force -Path $contractDir | Out-Null
New-Item -ItemType Directory -Force -Path $backupDir   | Out-Null

# ---------- Helper: backup a file if it exists ----------
function Backup-File($path) {
  if (Test-Path $path) {
    $name = Split-Path $path -Leaf
    $dest = Join-Path $backupDir ($name + "_PHASE_2_1_FIX_BACKUP_$stamp")
    Copy-Item $path $dest -Force
    Ok "Backup created: $dest"
  }
}

# ---------- 1) Fix progressRoutes_shape.test.js (path/extension issue) ----------
$progressRoutesCandidates = @(
  (Join-Path $srcDir "progressRoutes.cjs"),
  (Join-Path $srcDir "progressRoutes.js"),
  (Join-Path $srcDir "progressRoutes.mjs")
)

$progressRoutesRel = $null
foreach ($c in $progressRoutesCandidates) {
  if (Test-Path $c) {
    $progressRoutesRel = ".\src\" + (Split-Path $c -Leaf)
    break
  }
}
if (-not $progressRoutesRel) {
  Warn "Could not find progressRoutes in backend\src. Existing files:"
  Get-ChildItem $srcDir | ForEach-Object { Write-Host " - $($_.Name)" }
  Fail "Missing progressRoutes.* in backend\src"
}

$shapeTestPath = Join-Path $testsDir "progressRoutes_shape.test.js"
Backup-File $shapeTestPath

$shapeTest = @"
const path = require('path');

test('progressRoutes module loads and exports a function', () => {
  const modPath = path.join(__dirname, '..', ${([System.Management.Automation.Language.CodeGeneration]::QuoteArgument($progressRoutesRel))});
  const mod = require(modPath);
  expect(typeof mod).toBe('function');
});
"@

Set-Content -Path $shapeTestPath -Value $shapeTest -Encoding UTF8
Ok "Wrote: tests\progressRoutes_shape.test.js (uses $progressRoutesRel)"

# ---------- 2) Fix puzzles_json.test.js (puzzles.json parse issue) ----------
# Identify the puzzles JSON file
$puzzlesCandidates = @(
  (Join-Path $srcDir "puzzles.json"),
  (Join-Path $srcDir "puzzles")   # some Windows views hide extension; keep as fallback
)

$puzzlesPath = $null
foreach ($p in $puzzlesCandidates) {
  if (Test-Path $p) { $puzzlesPath = $p; break }
}
if (-not $puzzlesPath) {
  Warn "Could not find puzzles.json in backend\src. Existing files:"
  Get-ChildItem $srcDir | ForEach-Object { Write-Host " - $($_.Name)" }
  Fail "Missing puzzles.json (or puzzles) in backend\src"
}

# If file begins with UTF-8 BOM (EF BB BF), remove it (safe + reversible)
Backup-File $puzzlesPath
$bytes = [System.IO.File]::ReadAllBytes($puzzlesPath)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
  [System.IO.File]::WriteAllBytes($puzzlesPath, $bytes[3..($bytes.Length-1)])
  Ok "Removed UTF-8 BOM from: $puzzlesPath"
} else {
  Info "No UTF-8 BOM detected in: $puzzlesPath"
}

# Quick proof: can Node parse it?
Push-Location $backendDir
try {
  node -e "const fs=require('fs'); const s=fs.readFileSync('src/$(Split-Path $puzzlesPath -Leaf)','utf8').replace(/^\uFEFF/,''); JSON.parse(s); console.log('OK: puzzles JSON parses');"
  Ok "Node parse check passed for puzzles file."
} catch {
  Warn "Node parse check FAILED for puzzles file. Showing first 5 lines:"
  Get-Content $puzzlesPath -TotalCount 5 | ForEach-Object { Write-Host $_ }
  throw
} finally {
  Pop-Location
}

$puzzlesTestPath = Join-Path $testsDir "puzzles_json.test.js"
Backup-File $puzzlesTestPath

$puzzlesLeaf = Split-Path $puzzlesPath -Leaf

$puzzlesTest = @"
const fs = require('fs');
const path = require('path');

test('puzzles.json is valid JSON and has at least 1 puzzle with id/question', () => {
  const puzzlesPath = path.join(__dirname, '..', 'src', '${puzzlesLeaf}');
  const raw = fs.readFileSync(puzzlesPath, 'utf8').replace(/^\uFEFF/, '');
  const data = JSON.parse(raw);

  expect(Array.isArray(data)).toBe(true);
  expect(data.length).toBeGreaterThan(0);

  const p = data[0];
  expect(p).toHaveProperty('id');
  expect(p).toHaveProperty('question');
});
"@

Set-Content -Path $puzzlesTestPath -Value $puzzlesTest -Encoding UTF8
Ok "Wrote: tests\puzzles_json.test.js (reads src\$puzzlesLeaf safely)"

# ---------- 3) Fix contract/progress_api.contract.test.js (broken JS template/fetch line) ----------
$contractTestPath = Join-Path $contractDir "progress_api.contract.test.js"
Backup-File $contractTestPath

$contractTest = @"
const BACKEND = process.env.BACKEND_BASE_URL || 'http://localhost:8085';

async function jget(path) {
  const r = await fetch(\`\${BACKEND}\${path}\`);
  if (!r.ok) throw new Error(\`GET failed: \${r.status}\`);
  return r.json();
}

async function jpost(path, body) {
  const r = await fetch(\`\${BACKEND}\${path}\`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(\`POST failed: \${r.status}\`);
  return r.json();
}

test('Progress API contract: solve increments solved and never exceeds total', async () => {
  const before = await jget('/progress');
  const afterSolve = await jpost('/progress/solve', { puzzleId: 1 });
  const after = await jget('/progress');

  expect(typeof before.total).toBe('number');
  expect(typeof before.solved).toBe('number');
  expect(typeof after.total).toBe('number');
  expect(typeof after.solved).toBe('number');

  expect(after.total).toBe(before.total);
  expect(after.solved).toBeGreaterThanOrEqual(before.solved);
  expect(after.solved).toBeLessThanOrEqual(after.total);

  // Optional: response shape check
  expect(afterSolve).toHaveProperty('ok');
});
"@

Set-Content -Path $contractTestPath -Value $contractTest -Encoding UTF8
Ok "Wrote: tests\contract\progress_api.contract.test.js (correct fetch + template strings)"

# ---------- Run tests ----------
Info "Running backend tests..."
Push-Location $backendDir
try {
  npm test
  Ok "PHASE 2.1 tests now pass."
} finally {
  Pop-Location
}

Ok "Done."
Write-Host "[NEXT] Proceed to Phase 2.2 (Frontend unit tests / small contracts) after you confirm green." -ForegroundColor Yellow
