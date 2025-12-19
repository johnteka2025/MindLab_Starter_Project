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