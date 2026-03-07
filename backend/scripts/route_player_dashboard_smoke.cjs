"use strict";

const http = require("http");
const express = require("express");
const playerDashboardRouter = require("../src/routes/playerDashboard.cjs");

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
  app.use("/game", playerDashboardRouter);

  const server = app.listen(8101, "127.0.0.1");

  try {
    const result = await postJson(8101, "/game/player-dashboard", {
      player: "Maya",
      attempts: [
        { player: "Maya", date: "2026-03-01", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-02", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-03", ok: false, points: 0 },
        { player: "Maya", date: "2026-03-04", ok: true, points: 10 },
        { player: "Omar", date: "2026-03-01", ok: true, points: 50 }
      ],
      scoreboardEntries: [
        { player: "Omar", points: 50 },
        { player: "Maya", points: 30 },
        { player: "Lina", points: 20 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.player === "Maya", "expected player Maya");
    assert(result.body.result.profile.summary.totalPoints === 30, "expected totalPoints=30");
    assert(result.body.result.leaderboard.rank === 2, "expected rank=2");
    assert(result.body.result.leaderboard.points === 30, "expected points=30");
    assert(result.body.result.leaderboard.totalPlayers === 3, "expected totalPlayers=3");

    console.log("OK ROUTE PLAYER DASHBOARD SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
