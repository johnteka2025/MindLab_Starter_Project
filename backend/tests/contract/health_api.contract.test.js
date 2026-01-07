/**
 * Contract test: /health endpoint
 * Golden Rule: no side effects, no external deps, deterministic, CommonJS.
 */
const http = require("http");
const app = require("../../src/server.cjs");

function startServer(appInstance) {
  return new Promise((resolve, reject) => {
    const server = http.createServer(appInstance);

    server.on("error", (err) => reject(err));

    server.listen(0, "127.0.0.1", () => {
      const addr = server.address();
      resolve({ server, port: addr.port });
    });
  });
}

function httpGetJson(port, path) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: "127.0.0.1",
        port,
        path,
        method: "GET",
        headers: { Accept: "application/json" }
      },
      (res) => {
        let raw = "";
        res.setEncoding("utf8");
        res.on("data", (chunk) => (raw += chunk));
        res.on("end", () => {
          let body;
          try {
            body = raw ? JSON.parse(raw) : null;
          } catch (e) {
            return reject(new Error("Response was not valid JSON: " + raw));
          }
          resolve({ status: res.statusCode, body });
        });
      }
    );

    req.on("error", (err) => reject(err));
    req.end();
  });
}

describe("GET /health contract", () => {
  let server;
  let port;

  beforeAll(async () => {
    const started = await startServer(app);
    server = started.server;
    port = started.port;
  });

  afterAll(async () => {
    if (!server) return;
    await new Promise((resolve) => server.close(() => resolve()));
  });

  test("returns 200 and expected JSON shape", async () => {
    const res = await httpGetJson(port, "/health");

    expect(res.status).toBe(200);
    expect(res.body).toBeTruthy();
    expect(typeof res.body).toBe("object");

    expect(res.body).toHaveProperty("status");
    expect(res.body.status).toBe("ok");

    if (Object.prototype.hasOwnProperty.call(res.body, "uptime")) {
      expect(typeof res.body.uptime).toBe("number");
    }
  });
});
