"use strict";

const http = require("http");
const express = require("express");
const playerProfileRouter = require("../src/routes/playerProfile.cjs");

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
  app.use("/game", playerProfileRouter);

  const server = app.listen(8100, "127.0.0.1");

  try {
    const result = await postJson(8100, "/game/player-profile", {
      player: "Maya",
      attempts: [
        { player: "Maya", date: "2026-03-01", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-02", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-03", ok: false, points: 0 },
        { player: "Maya", date: "2026-03-04", ok: true, points: 10 },
        { player: "Omar", date: "2026-03-01", ok: true, points: 10 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.player === "Maya", "expected player Maya");
    assert(result.body.result.summary.totalAttempts === 4, "expected totalAttempts=4");
    assert(result.body.result.summary.totalCorrect === 3, "expected totalCorrect=3");
    assert(result.body.result.summary.totalPoints === 30, "expected totalPoints=30");
    assert(result.body.result.streak.bestStreak === 2, "expected bestStreak=2");
    assert(Array.isArray(result.body.result.achievement.achievements), "expected achievements array");
    assert(result.body.result.achievement.achievements.includes("first-correct"), "expected first-correct");

    console.log("OK ROUTE PLAYER PROFILE SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
