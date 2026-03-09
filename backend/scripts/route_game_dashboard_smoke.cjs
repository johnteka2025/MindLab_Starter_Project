"use strict";

const http = require("http");
const express = require("express");
const router = require("../src/routes/gameDashboard.cjs");

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

  const server = app.listen(8116, "127.0.0.1");

  try {
    const result = await postJson(8116, "/game/game-dashboard", {
      player: "Maya",
      attempts: [
        { player: "Maya", date: "2026-03-01", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-02", ok: false, points: 0 },
        { player: "Maya", date: "2026-03-03", ok: true, points: 10 }
      ],
      scoreboardEntries: [
        { player: "Omar", points: 50 },
        { player: "Maya", points: 20 },
        { player: "Lina", points: 10 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.player === "Maya", "expected player Maya");
    assert(result.body.result.playerDashboard.leaderboard.rank === 2, "expected player rank=2");
    assert(result.body.result.leaderboard.topPlayer === "Omar", "expected topPlayer Omar");
    assert(result.body.result.leaderboard.totalPlayers === 3, "expected totalPlayers=3");
    assert(typeof result.body.result.overview.question === "string", "expected overview question");

    console.log("OK ROUTE GAME DASHBOARD SMOKE PASSED");
  } finally {
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
