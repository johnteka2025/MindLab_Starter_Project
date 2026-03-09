"use strict";

const http = require("http");
const express = require("express");
const router = require("../src/routes/leaderboardIntelligence.cjs");

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

  const server = app.listen(8115, "127.0.0.1");

  try {
    const result = await postJson(8115, "/game/leaderboard-intelligence", {
      entries: [
        { player: "Omar", points: 50 },
        { player: "Maya", points: 30 },
        { player: "Lina", points: 20 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.totalPlayers === 3, "expected totalPlayers=3");
    assert(result.body.result.topPlayer === "Omar", "expected topPlayer Omar");
    assert(result.body.result.topPoints === 50, "expected topPoints 50");
    assert(result.body.result.gapToSecond === 20, "expected gapToSecond 20");
    assert(Array.isArray(result.body.result.scoreboard), "expected scoreboard array");

    console.log("OK ROUTE LEADERBOARD INTELLIGENCE SMOKE PASSED");
  } finally {
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
