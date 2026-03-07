"use strict";

const http = require("http");
const express = require("express");
const sessionSnapshotRouter = require("../src/routes/sessionSnapshot.cjs");

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
  app.use("/game", sessionSnapshotRouter);

  const server = app.listen(8103, "127.0.0.1");

  try {
    const result = await postJson(8103, "/game/session-snapshot", {
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
    assert(result.body.result.dashboard.leaderboard.rank === 2, "expected rank=2");
    assert(result.body.result.dashboard.profile.summary.totalPoints === 30, "expected totalPoints=30");
    assert(typeof result.body.result.overview.question === "string", "expected overview question");

    console.log("OK ROUTE SESSION SNAPSHOT SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
