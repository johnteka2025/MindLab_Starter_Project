# PATCH_16_backend_add_progress_persistence_json.ps1
# Adds backend/src/progressPersistence.cjs + wires it into backend/src/server.cjs
# Golden Rules: backups, correct paths, sanity build, return to root

$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$label) {
  if (-not (Test-Path $p)) { throw "Missing required ${label}: ${p}" }
}

$ROOT = "C:\Projects\MindLab_Starter_Project"
$BACKEND = Join-Path $ROOT "backend"
$SRC = Join-Path $BACKEND "src"
$server = Join-Path $SRC "server.cjs"
$persist = Join-Path $SRC "progressPersistence.cjs"
$dataDir = Join-Path $SRC "data"
$dataFile = Join-Path $dataDir "progress.json"

Assert-Path $ROOT "project root"
Assert-Path $BACKEND "backend folder"
Assert-Path $SRC "backend/src folder"
Assert-Path $server "backend/src/server.cjs"

Set-Location $ROOT
$ts = Get-Date -Format "yyyyMMdd_HHmmss"

# --- Backup server.cjs
Copy-Item $server "$server.bak_persist_$ts" -Force
Write-Host "Backup created: $server.bak_persist_$ts" -ForegroundColor Green

# --- Ensure data directory exists
if (-not (Test-Path $dataDir)) { New-Item -ItemType Directory -Path $dataDir | Out-Null }

# --- Write progressPersistence.cjs (full file)
@'
const fs = require("fs");
const path = require("path");

function safeJsonParse(text) {
  try { return JSON.parse(text); } catch { return null; }
}

function ensureDir(p) {
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function pick(obj, key, fallback) {
  return Object.prototype.hasOwnProperty.call(obj, key) ? obj[key] : fallback;
}

function normalizeLoadedState(raw) {
  const o = (raw && typeof raw === "object") ? raw : {};
  // Keep only known keys; allow future keys safely
  const out = {
    total: typeof o.total === "number" ? o.total : 0,
    solved: typeof o.solved === "number" ? o.solved : 0,
    solvedToday: typeof o.solvedToday === "number" ? o.solvedToday : 0,
    totalSolved: typeof o.totalSolved === "number" ? o.totalSolved : 0,
    streak: typeof o.streak === "number" ? o.streak : 0,
    solvedIds: Array.isArray(o.solvedIds) ? o.solvedIds : [],
    solvedPuzzleIds: (o.solvedPuzzleIds && typeof o.solvedPuzzleIds === "object") ? o.solvedPuzzleIds : {}
  };
  return out;
}

function deepProxy(target, onChange, seen = new WeakMap()) {
  if (!target || typeof target !== "object") return target;
  if (seen.has(target)) return seen.get(target);

  const proxied = new Proxy(target, {
    get(obj, prop) {
      const val = obj[prop];
      // Proxy nested objects/arrays too
      return deepProxy(val, onChange, seen);
    },
    set(obj, prop, value) {
      obj[prop] = value;
      onChange();
      return true;
    },
    deleteProperty(obj, prop) {
      delete obj[prop];
      onChange();
      return true;
    }
  });

  seen.set(target, proxied);
  return proxied;
}

module.exports = function initProgressPersistence(options = {}) {
  const dataFile = options.dataFile || path.join(__dirname, "data", "progress.json");
  ensureDir(path.dirname(dataFile));

  // If progress store doesn't exist yet, nothing to do.
  if (!globalThis.__mindlabProgress) {
    console.warn("[progressPersistence] globalThis.__mindlabProgress not found (yet).");
    return;
  }

  // Load saved state (merge into existing store)
  if (fs.existsSync(dataFile)) {
    const raw = safeJsonParse(fs.readFileSync(dataFile, "utf8"));
    const loaded = normalizeLoadedState(raw);

    const p = globalThis.__mindlabProgress;

    // Merge carefully: keep runtime object identity, update fields
    p.total = loaded.total || p.total || 0;
    p.solved = loaded.solved || 0;
    p.solvedToday = loaded.solvedToday || 0;
    p.totalSolved = loaded.totalSolved || 0;
    p.streak = loaded.streak || 0;

    // solvedIds array + solvedPuzzleIds map
    p.solvedIds = Array.isArray(loaded.solvedIds) ? loaded.solvedIds.slice() : (p.solvedIds || []);
    p.solvedPuzzleIds = (loaded.solvedPuzzleIds && typeof loaded.solvedPuzzleIds === "object")
      ? { ...loaded.solvedPuzzleIds }
      : (p.solvedPuzzleIds || {});
  }

  let saveTimer = null;
  function saveNow() {
    try {
      const p = globalThis.__mindlabProgress || {};
      const snapshot = {
        total: p.total || 0,
        solved: p.solved || 0,
        solvedToday: p.solvedToday || 0,
        totalSolved: p.totalSolved || 0,
        streak: p.streak || 0,
        solvedIds: Array.isArray(p.solvedIds) ? p.solvedIds : [],
        solvedPuzzleIds: (p.solvedPuzzleIds && typeof p.solvedPuzzleIds === "object") ? p.solvedPuzzleIds : {}
      };

      const tmp = dataFile + ".tmp";
      fs.writeFileSync(tmp, JSON.stringify(snapshot, null, 2) + "\n", "utf8");
      fs.renameSync(tmp, dataFile);
    } catch (e) {
      console.warn("[progressPersistence] save failed:", String(e));
    }
  }

  function scheduleSave() {
    if (saveTimer) clearTimeout(saveTimer);
    saveTimer = setTimeout(saveNow, 50);
  }

  // Wrap progress object so ANY mutation triggers save (including nested keys)
  globalThis.__mindlabProgress = deepProxy(globalThis.__mindlabProgress, scheduleSave);

  // Save once after init to ensure file exists
  saveNow();

  // Save on exit
  process.on("SIGINT", () => { saveNow(); process.exit(0); });
  process.on("SIGTERM", () => { saveNow(); process.exit(0); });
  process.on("exit", () => { saveNow(); });

  console.log("[progressPersistence] enabled:", dataFile);
};
'@ | Set-Content -Path $persist -Encoding UTF8

Write-Host "Created/Updated: $persist" -ForegroundColor Green

# --- Patch server.cjs to require persistence AFTER progress routes are registered
$serverText = Get-Content -Path $server -Raw -Encoding UTF8

$needle = "registerProgressRoutes(app);"
if ($serverText -notmatch [regex]::Escape($needle)) {
  throw "Could not find expected line in server.cjs: $needle"
}

# Avoid double-inserting if re-run
if ($serverText -match "progressPersistence\.cjs") {
  Write-Host "server.cjs already references progressPersistence.cjs (no duplicate insert)." -ForegroundColor Yellow
} else {
  $insert = @'
registerProgressRoutes(app);

// Enable JSON persistence for progress (Phase 4B)
const initProgressPersistence = require("./progressPersistence.cjs");
initProgressPersistence();
'@

  $serverText = $serverText -replace [regex]::Escape("registerProgressRoutes(app);"), $insert
  Set-Content -Path $server -Value $serverText -Encoding UTF8
  Write-Host "Patched: $server" -ForegroundColor Green
}

# --- Create data file if missing (optional; module will create it anyway)
if (-not (Test-Path $dataFile)) {
  @"
{
  "total": 0,
  "solved": 0,
  "solvedToday": 0,
  "totalSolved": 0,
  "streak": 0,
  "solvedIds": [],
  "solvedPuzzleIds": {}
}
"@ | Set-Content -Path $dataFile -Encoding UTF8
  Write-Host "Created seed data file: $dataFile" -ForegroundColor Green
}

Set-Location $ROOT
Write-Host "PATCH_16 GREEN: JSON progress persistence added." -ForegroundColor Green
Write-Host "Returned to project root: $ROOT" -ForegroundColor Green
