"use strict";

const http = require("http");
const express = require("express");
const gameOverviewRouter = require("../src/routes/gameOverview.cjs");

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
  app.use("/game", gameOverviewRouter);

  const server = app.listen(8102, "127.0.0.1");

  try {
    const result = await postJson(8102, "/game/game-overview", {
      scoreboardEntries: [
        { player: "Omar", points: 50 },
        { player: "Maya", points: 30 },
        { player: "Lina", points: 20 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result, "expected result");
    assert(typeof result.body.result.date === "string", "expected date");
    assert(typeof result.body.result.question === "string", "expected question");
    assert(result.body.result.leaderboard.totalPlayers === 3, "expected totalPlayers=3");
    assert(Array.isArray(result.body.result.leaderboard.scoreboard), "expected scoreboard array");
    assert(result.body.result.leaderboard.scoreboard[0].player === "Omar", "expected Omar rank 1");

    console.log("OK ROUTE GAME OVERVIEW SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
