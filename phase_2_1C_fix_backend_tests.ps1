param()

$ErrorActionPreference = "Stop"

function Stamp { Get-Date -Format "yyyyMMdd_HHmmss" }
function Say($m){ Write-Host $m }
function Ok($m){ Write-Host "[OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[ERROR] $m" -ForegroundColor Red; throw $m }

$startDir = Get-Location
try {
  $projectRoot = "C:\Projects\MindLab_Starter_Project"
  $backendDir  = Join-Path $projectRoot "backend"
  $srcDir      = Join-Path $backendDir  "src"
  $testsDir    = Join-Path $backendDir  "tests"
  $contractDir = Join-Path $testsDir    "contract"
  $backupDir   = Join-Path $backendDir  ("backups\manual_edits\PHASE_2_1C_FIX_" + (Stamp))

  Say "[INFO] === Phase 2.1C: Fix backend test inputs and contract test ==="
  Say "[INFO] ProjectRoot: $projectRoot"
  Say "[INFO] BackendDir : $backendDir"

  if (-not (Test-Path $projectRoot)) { Fail "Missing project root: $projectRoot" }
  if (-not (Test-Path $backendDir))  { Fail "Missing backend dir: $backendDir" }
  if (-not (Test-Path $srcDir))      { Fail "Missing backend/src: $srcDir" }

  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  New-Item -ItemType Directory -Force -Path $testsDir | Out-Null
  New-Item -ItemType Directory -Force -Path $contractDir | Out-Null

  # -----------------------------
  # 1) Ensure backend/src/puzzles.json is valid JSON
  # -----------------------------
  $puzzlesPath = Join-Path $srcDir "puzzles.json"
  if (-not (Test-Path $puzzlesPath)) { Fail "Missing: $puzzlesPath" }

  $puzzlesBackup = Join-Path $backupDir ("puzzles.json_PRE_" + (Stamp))
  Copy-Item $puzzlesPath $puzzlesBackup -Force
  Ok "Backed up puzzles.json -> $puzzlesBackup"

  # Remove UTF-8 BOM if present
  $bytes = [System.IO.File]::ReadAllBytes($puzzlesPath)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
    [System.IO.File]::WriteAllBytes($puzzlesPath, $bytes[3..($bytes.Length-1)])
    Ok "Removed UTF-8 BOM from puzzles.json"
  } else {
    Say "[INFO] No BOM detected in puzzles.json"
  }

  # Validate JSON parse using Node
  $puzzlesParseOk = $true
  try {
    node -e "const fs=require('fs'); JSON.parse(fs.readFileSync('backend/src/puzzles.json','utf8')); console.log('OK puzzles.json parses');" | Out-Null
  } catch {
    $puzzlesParseOk = $false
  }

  if (-not $puzzlesParseOk) {
    Warn "puzzles.json is not valid JSON. Attempting conversion from JS-style content."

    $raw = Get-Content -Raw -Path $puzzlesPath -Encoding UTF8

    $i1 = $raw.IndexOf('[')
    $i2 = $raw.LastIndexOf(']')
    if ($i1 -lt 0 -or $i2 -le $i1) {
      Fail "Could not find array brackets [ ... ] inside puzzles.json."
    }

    $arrayLiteral = $raw.Substring($i1, ($i2 - $i1 + 1))

    # Write a temp JS file that exports the array literal (so Node can require it)
    $tmpJsName  = "puzzles_tmp_" + (Stamp) + ".js"
    $tmpOutName = "puzzles_converted_" + (Stamp) + ".json"
    $tmpJs  = Join-Path $backupDir $tmpJsName
    $tmpOut = Join-Path $backupDir $tmpOutName

    Set-Content -Path $tmpJs -Value ("module.exports = " + $arrayLiteral + ";") -Encoding UTF8

    # Use Node to require the temp file and write proper JSON
    $nodeCode = "const p=require(process.argv[1]); const fs=require('fs'); fs.writeFileSync(process.argv[2], JSON.stringify(p,null,2), 'utf8');"
    node -e $nodeCode $tmpJs $tmpOut | Out-Null

    Copy-Item $tmpOut $puzzlesPath -Force
    Ok "Converted puzzles.json to valid JSON."

    node -e "const fs=require('fs'); JSON.parse(fs.readFileSync('backend/src/puzzles.json','utf8')); console.log('OK puzzles.json parses AFTER convert');" | Out-Null
    Ok "Verified puzzles.json parses."
  } else {
    Ok "puzzles.json already valid JSON."
  }

  # -----------------------------
  # 2) Write tests (robust paths)
  # -----------------------------

  # tests/progressRoutes_shape.test.js
  $t1 = Join-Path $testsDir "progressRoutes_shape.test.js"
  if (Test-Path $t1) {
    Copy-Item $t1 (Join-Path $backupDir ("progressRoutes_shape.test.js_PRE_" + (Stamp))) -Force
    Ok "Backed up progressRoutes_shape.test.js"
  }

  $t1Content = @'
const path = require("path");

test("progressRoutes module loads and exports a function", () => {
  const modPath = path.resolve(__dirname, "..", "src", "progressRoutes.cjs");
  const mod = require(modPath);
  expect(typeof mod).toBe("function");
});
'@
  Set-Content -Path $t1 -Value $t1Content -Encoding UTF8
  Ok "Wrote tests/progressRoutes_shape.test.js"

  # tests/puzzles_json.test.js
  $t2 = Join-Path $testsDir "puzzles_json.test.js"
  if (Test-Path $t2) {
    Copy-Item $t2 (Join-Path $backupDir ("puzzles_json.test.js_PRE_" + (Stamp))) -Force
    Ok "Backed up puzzles_json.test.js"
  }

  $t2Content = @'
const fs = require("fs");
const path = require("path");

test("puzzles.json is valid JSON and has at least 1 puzzle with id/question", () => {
  const puzzlesPath = path.resolve(__dirname, "..", "src", "puzzles.json");
  const raw = fs.readFileSync(puzzlesPath, "utf8").replace(/^\uFEFF/, "");
  const data = JSON.parse(raw);

  expect(Array.isArray(data)).toBe(true);
  expect(data.length).toBeGreaterThan(0);

  const first = data[0];
  expect(first).toHaveProperty("id");
  expect(first).toHaveProperty("question");
});
'@
  Set-Content -Path $t2 -Value $t2Content -Encoding UTF8
  Ok "Wrote tests/puzzles_json.test.js"

  # tests/contract/progress_api.contract.test.js
  $t3 = Join-Path $contractDir "progress_api.contract.test.js"
  if (Test-Path $t3) {
    Copy-Item $t3 (Join-Path $backupDir ("progress_api.contract.test.js_PRE_" + (Stamp))) -Force
    Ok "Backed up progress_api.contract.test.js"
  }

  $t3Content = @'
const BASE = process.env.BACKEND_URL || "http://localhost:8085";

async function getJson(path) {
  const r = await fetch(`${BASE}${path}`);
  if (!r.ok) throw new Error(`GET failed: ${r.status} ${r.statusText}`);
  return await r.json();
}

test("Progress API contract: GET /progress returns {total, solved} numbers", async () => {
  const data = await getJson("/progress");
  expect(typeof data.total).toBe("number");
  expect(typeof data.solved).toBe("number");
  expect(data.solved).toBeLessThanOrEqual(data.total);
});
'@
  Set-Content -Path $t3 -Value $t3Content -Encoding UTF8
  Ok "Wrote tests/contract/progress_api.contract.test.js"

  # -----------------------------
  # 3) Run tests
  # -----------------------------
  Say ""
  Say "[INFO] Running backend tests (npm test)..."
  Push-Location $backendDir
  try {
    npm test
    Ok "Backend tests finished."
  } finally {
    Pop-Location
  }

  Ok "Phase 2.1C complete."
  Say "[INFO] Backups in: $backupDir"
}
finally {
  Set-Location $startDir
  Say "[INFO] Returned to: $((Get-Location).Path)"
  Read-Host "Press ENTER to continue"
}
