"use strict";

const http = require("http");
const express = require("express");
const playerAchievementRouter = require("../src/routes/playerAchievement.cjs");

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
  app.use("/game", playerAchievementRouter);

  const server = app.listen(8099, "127.0.0.1");

  try {
    const result = await postJson(8099, "/game/player-achievement", {
      totalCorrect: 5,
      bestStreak: 3,
      totalPoints: 60
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(Array.isArray(result.body.result.achievements), "expected achievements array");
    assert(result.body.result.achievements.includes("first-correct"), "expected first-correct");
    assert(result.body.result.achievements.includes("streak-3"), "expected streak-3");
    assert(result.body.result.achievements.includes("points-50"), "expected points-50");

    console.log("OK ROUTE PLAYER ACHIEVEMENT SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
