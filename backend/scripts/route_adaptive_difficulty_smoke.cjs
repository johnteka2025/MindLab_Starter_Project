"use strict";

const http = require("http");
const express = require("express");
const router = require("../src/routes/adaptiveDifficulty.cjs");

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
        res.on("data", chunk => { raw += chunk; });
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
  app.use("/game", router);

  const server = app.listen(8114, "127.0.0.1");

  try {
    const result = await postJson(8114, "/game/adaptive-difficulty", {
      player: "Maya",
      attempts: [
        { player: "Maya", date: "2026-03-01", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-02", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-03", ok: true, points: 10 },
        { player: "Omar", date: "2026-03-01", ok: true, points: 50 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.player === "Maya", "expected player Maya");
    assert(result.body.result.totalAttempts === 3, "expected totalAttempts=3");
    assert(result.body.result.successRate === 100, "expected successRate=100");
    assert(result.body.result.bestStreak === 3, "expected bestStreak=3");
    assert(result.body.result.recommendedDifficulty === "hard", "expected recommendedDifficulty=hard");

    console.log("OK ROUTE ADAPTIVE DIFFICULTY SMOKE PASSED");
  } finally {
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
