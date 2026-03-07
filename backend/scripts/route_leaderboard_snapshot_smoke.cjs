"use strict";

const http = require("http");
const express = require("express");
const leaderboardSnapshotRouter = require("../src/routes/leaderboardSnapshot.cjs");

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
  app.use("/game", leaderboardSnapshotRouter);

  const server = app.listen(8095, "127.0.0.1");

  try {
    const result = await postJson(8095, "/game/leaderboard-snapshot", {
      entries: [
        { player: "Maya", points: 30 },
        { player: "Omar", points: 50 },
        { player: "Lina", points: 40 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.snapshot, "expected snapshot");
    assert(result.body.snapshot.totalPlayers === 3, "expected totalPlayers=3");
    assert(Array.isArray(result.body.snapshot.scoreboard), "expected scoreboard array");
    assert(result.body.snapshot.scoreboard[0].player === "Omar", "expected Omar rank 1");

    console.log("OK ROUTE LEADERBOARD SNAPSHOT SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
