const http = require('http');

function startServer(app) {
  return new Promise((resolve, reject) => {
    const server = http.createServer(app);
    server.on('error', reject);
    server.listen(0, '127.0.0.1', () => {
      const addr = server.address();
      const baseUrl = http://127.0.0.1:;
      resolve({ server, baseUrl });
    });
  });
}

async function getJson(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(GET failed:  );
  return await r.json();
}

describe('Health API contract', () => {
  let server;
  let baseUrl;

  beforeAll(async () => {
    const mod = require('../../src/server.cjs');
    if (!mod || !mod.app) throw new Error('server.cjs must export { app }');
    const started = await startServer(mod.app);
    server = started.server;
    baseUrl = started.baseUrl;
  });

  afterAll(async () => {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
  });

  test('GET /health returns { ok: true }', async () => {
    const data = await getJson(${baseUrl}/health);
    expect(data).toHaveProperty('ok', true);
  });
});