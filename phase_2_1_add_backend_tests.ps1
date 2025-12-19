$ErrorActionPreference = "Stop"

function Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; exit 1 }

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$backendDir  = Join-Path $projectRoot "backend"
$srcDir      = Join-Path $backendDir  "src"
$pkgPath     = Join-Path $backendDir  "package.json"

if (-not (Test-Path $backendDir)) { Fail "Missing backend folder: $backendDir" }
if (-not (Test-Path $pkgPath))    { Fail "Missing backend package.json: $pkgPath" }

# Backup package.json
$backupDir = Join-Path $backendDir "backups\manual_edits"
New-Item -ItemType Directory -Force $backupDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$pkgBackup = Join-Path $backupDir ("package.json_PHASE_2_1_BACKUP_" + $stamp)
Copy-Item $pkgPath $pkgBackup -Force
Ok "Backed up package.json => $pkgBackup"

# Load/patch package.json
$pkgRaw = Get-Content $pkgPath -Raw -Encoding UTF8
$pkg = $pkgRaw | ConvertFrom-Json

if ($null -eq $pkg.devDependencies) { $pkg | Add-Member -NotePropertyName devDependencies -NotePropertyValue (@{}) }
if ($null -eq $pkg.scripts)         { $pkg | Add-Member -NotePropertyName scripts         -NotePropertyValue (@{}) }

$needsInstall = $false
if (-not $pkg.devDependencies.PSObject.Properties.Name.Contains("jest")) {
  $pkg.devDependencies | Add-Member -NotePropertyName "jest" -NotePropertyValue "^29.7.0"
  $needsInstall = $true
  Ok "Added jest to devDependencies (will install)."
} else {
  Info "jest already present in devDependencies."
}

if (-not $pkg.scripts.PSObject.Properties.Name.Contains("test")) {
  $pkg.scripts | Add-Member -NotePropertyName "test" -NotePropertyValue "jest"
  Ok "Added scripts.test = jest"
} else {
  Info "scripts.test already exists (leaving as-is): $($pkg.scripts.test)"
}

Set-Content -Path $pkgPath -Value ($pkg | ConvertTo-Json -Depth 50) -Encoding UTF8
Ok "Saved package.json"

# Create tests directories
$testsDir = Join-Path $backendDir "tests"
$contractDir = Join-Path $testsDir "contract"
New-Item -ItemType Directory -Force $testsDir | Out-Null
New-Item -ItemType Directory -Force $contractDir | Out-Null
Ok "Ensured test dirs: $testsDir and $contractDir"

# Test 1: puzzles.json structure
$puzzlesTest = @"
const fs = require("fs");
const path = require("path");

test("puzzles.json is valid JSON and has at least 1 puzzle with id/question", () => {
  const puzzlesPath = path.join(__dirname, "..", "src", "puzzles.json");
  expect(fs.existsSync(puzzlesPath)).toBe(true);

  const raw = fs.readFileSync(puzzlesPath, "utf8");
  const data = JSON.parse(raw);

  expect(Array.isArray(data)).toBe(true);
  expect(data.length).toBeGreaterThan(0);

  for (const p of data) {
    expect(p).toHaveProperty("id");
    expect(typeof p.id === "number" || typeof p.id === "string").toBe(true);
    expect(p).toHaveProperty("question");
    expect(typeof p.question).toBe("string");
  }
});
"@
Set-Content -Path (Join-Path $testsDir "puzzles_json.test.js") -Value $puzzlesTest -Encoding UTF8
Ok "Created: tests\puzzles_json.test.js"

# Test 2: progressRoutes module shape
$routesTest = @"
test("progressRoutes.js loads and exports a function", () => {
  const mod = require("../src/progressRoutes.js");
  expect(typeof mod).toBe("function");
});
"@
Set-Content -Path (Join-Path $testsDir "progressRoutes_shape.test.js") -Value $routesTest -Encoding UTF8
Ok "Created: tests\progressRoutes_shape.test.js"

# Test 3: contract (requires backend running on 8085)
$contractTest = @"
const BACKEND = process.env.MINDLAB_BACKEND_URL || "http://localhost:8085";

async function jget(path) {
  const r = await fetch(`${BACKEND}${path}`);
  if (!r.ok) throw new Error(`GET ${path} failed: ${r.status}`);
  return r.json().catch(() => ({}));
}

async function jpost(path, body) {
  const r = await fetch(`${BACKEND}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`POST ${path} failed: ${r.status}`);
  return r.json().catch(() => ({}));
}

test("contract: /health, /progress, /progress/solve behave (backend must be running)", async () => {
  const h = await fetch(`${BACKEND}/health`);
  expect(h.ok).toBe(true);

  const before = await jget("/progress");
  expect(typeof before.total).toBe("number");
  expect(typeof before.solved).toBe("number");
  expect(before.solved).toBeGreaterThanOrEqual(0);
  expect(before.total).toBeGreaterThanOrEqual(0);
  expect(before.solved).toBeLessThanOrEqual(before.total);

  await jpost("/progress/solve", { puzzleId: 1 });

  const after = await jget("/progress");
  expect(after.solved).toBeGreaterThanOrEqual(before.solved);
  expect(after.solved).toBeLessThanOrEqual(after.total);
}, 15000);
"@
Set-Content -Path (Join-Path $contractDir "progress_api.contract.test.js") -Value $contractTest -Encoding UTF8
Ok "Created: tests\contract\progress_api.contract.test.js"

Push-Location $backendDir
try {
  if ($needsInstall) {
    Info "Installing deps (npm install)..."
    npm install
    Ok "npm install complete."
  } else {
    Info "Skipping npm install (jest already present)."
  }

  Info "Running unit tests..."
  npx jest tests\puzzles_json.test.js tests\progressRoutes_shape.test.js --reporter=default
  Ok "Unit tests passed."

  Info "Running contract test (backend must be running on http://localhost:8085)..."
  npx jest tests\contract\progress_api.contract.test.js --reporter=default
  Ok "Contract test passed."
}
finally {
  Pop-Location
}

Ok "PHASE 2.1 complete."
