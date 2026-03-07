"use strict";

const http = require("http");
const express = require("express");
const playerStreakRouter = require("../src/routes/playerStreak.cjs");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function postJson(port, path, payload) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify(payload);

    const req = http.request(
      {
        hostname: "127.0.0.1",
        port,
        path,
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
        }
      },
      (res) => {
        let raw = "";
        res.setEncoding("utf8");
        res.on("data", (chunk) => { raw += chunk; });
        res.on("end", () => {
          try {
            resolve({
              statusCode: res.statusCode,
              body: raw ? JSON.parse(raw) : {}
            });
          } catch (err) {
            reject(err);
          }
        });
      }
    );

    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

async function main() {
  const app = express();
  app.use(express.json());
  app.use("/game", playerStreakRouter);

  const server = app.listen(8098, "127.0.0.1");

  try {
    const result = await postJson(8098, "/game/player-streak", {
      attempts: [
        { date: "2026-03-01", ok: true },
        { date: "2026-03-02", ok: true },
        { date: "2026-03-03", ok: false },
        { date: "2026-03-04", ok: true },
        { date: "2026-03-05", ok: true },
        { date: "2026-03-06", ok: true }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.totalAttempts === 6, "expected totalAttempts=6");
    assert(result.body.result.currentStreak === 3, "expected currentStreak=3");
    assert(result.body.result.bestStreak === 3, "expected bestStreak=3");

    console.log("OK ROUTE PLAYER STREAK SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
