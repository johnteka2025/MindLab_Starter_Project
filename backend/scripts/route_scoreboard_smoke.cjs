"use strict";

const http = require("http");
const express = require("express");
const scoreboardRouter = require("../src/routes/scoreboard.cjs");

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
  app.use("/game", scoreboardRouter);

  const server = app.listen(8094, "127.0.0.1");

  try {
    const result = await postJson(8094, "/game/scoreboard", {
      entries: [
        { player: "Maya", points: 30 },
        { player: "Omar", points: 50 },
        { player: "Lina", points: 40 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.count === 3, "expected count=3");
    assert(Array.isArray(result.body.scoreboard), "expected scoreboard array");
    assert(result.body.scoreboard[0].player === "Omar", "expected Omar rank 1");
    assert(result.body.scoreboard[0].points === 50, "expected Omar points 50");
    assert(result.body.scoreboard[1].player === "Lina", "expected Lina rank 2");
    assert(result.body.scoreboard[2].player === "Maya", "expected Maya rank 3");

    console.log("OK ROUTE SCOREBOARD SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
