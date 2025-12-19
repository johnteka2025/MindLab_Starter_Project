# fix_phase_2_2F_backend_contract_test_selfhost.ps1
# Purpose: Make progress_api.contract test self-contained by starting backend server during the test.
# Project: MindLab_Starter_Project

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Fail($m){ Write-Host "[FAIL] $m" -ForegroundColor Red; throw $m }

$startDir = Get-Location

try {
  $ProjectRoot = "C:\Projects\MindLab_Starter_Project"
  $BackendDir  = Join-Path $ProjectRoot "backend"

  $target = Join-Path $BackendDir "tests\contract\progress_api.contract.test.js"

  if (!(Test-Path $BackendDir)) { Fail "BackendDir not found: $BackendDir" }
  if (!(Test-Path $target)) { Fail "Target test file not found: $target" }

  # Backup
  $backupRoot = Join-Path $ProjectRoot "backups\manual_edits"
  if (!(Test-Path $backupRoot)) { New-Item -ItemType Directory -Path $backupRoot | Out-Null }

  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $backupDir = Join-Path $backupRoot ("PHASE_2_2F_BACKEND_CONTRACT_{0}" -f $stamp)
  New-Item -ItemType Directory -Path $backupDir | Out-Null

  Copy-Item $target (Join-Path $backupDir "progress_api.contract.test.js.BEFORE") -Force
  Ok "Backup created: $backupDir"

  # New test content (self-host server during test)
  $code = @'
/**
 * progress_api.contract.test.js
 * Contract test that self-hosts the backend server during the test run.
 * This removes reliance on a pre-running server (especially important after auto port cleanup).
 */

const { spawn } = require('child_process');

jest.setTimeout(60_000);

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function waitForOk(url, attempts = 60, delayMs = 500) {
  let lastErr;
  for (let i = 0; i < attempts; i++) {
    try {
      const r = await fetch(url, { method: 'GET' });
      if (r.ok) return true;
    } catch (e) {
      lastErr = e;
    }
    await sleep(delayMs);
  }
  throw lastErr || new Error(`Timed out waiting for OK: ${url}`);
}

describe('Progress API contract', () => {
  let child = null;
  let BASE = null;
  let port = null;

  beforeAll(async () => {
    // Use a dedicated test port so we don't depend on :8085 or any external process.
    // If this port is busy, try the next few.
    const candidates = [18085, 18086, 18087, 18088, 18089];

    for (const p of candidates) {
      // Start backend as a child process using this port
      const env = {
        ...process.env,
        PORT: String(p),
        NODE_ENV: 'test',
      };

      const c = spawn(process.execPath, ['src/server.cjs'], {
        cwd: process.cwd(),      // backend/
        env,
        stdio: 'ignore',         // keep output quiet; change to 'inherit' if debugging
        windowsHide: true,
      });

      // If it exits immediately, try next port
      await sleep(500);
      if (c.exitCode !== null) {
        try { c.kill('SIGKILL'); } catch {}
        continue;
      }

      const base = `http://127.0.0.1:${p}`;

      // Wait until server responds (use /health if available, else fall back to root)
      try {
        await waitForOk(`${base}/health`).catch(async () => {
          await waitForOk(`${base}/`);
        });

        child = c;
        port = p;
        BASE = base;
        return;
      } catch (e) {
        try { c.kill('SIGKILL'); } catch {}
        continue;
      }
    }

    throw new Error('Could not start backend server on any candidate test port.');
  });

  afterAll(async () => {
    if (child) {
      try { child.kill('SIGKILL'); } catch {}
      child = null;
    }
  });

  async function getJson(path) {
    const r = await fetch(`${BASE}${path}`);
    if (!r.ok) throw new Error(`GET failed: ${r.status} ${r.statusText}`);
    return await r.json();
  }

  test('GET /progress returns {total, solved} numbers', async () => {
    const data = await getJson('/progress');
    expect(typeof data.total).toBe('number');
    expect(typeof data.solved).toBe('number');
  });
});
'@

  # Write UTF-8 (no BOM)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($target, $code, $utf8NoBom)
  Ok "Patched: $target"

  # Quick sanity: ensure file contains our key markers
  $check = Get-Content -Raw $target
  if ($check -notmatch "self-hosts the backend server" -or $check -notmatch "spawn") {
    Fail "Sanity check failed: patched content does not look correct."
  }
  Ok "Sanity check OK"

  # Run backend tests
  Push-Location $BackendDir
  Info "Running backend tests..."
  cmd.exe /c "npm test"
  Pop-Location

  Ok "Phase 2.2F complete: backend contract test is now self-contained."
}
finally {
  Set-Location $startDir
  Info "Returned to: $((Get-Location).Path)"
}
