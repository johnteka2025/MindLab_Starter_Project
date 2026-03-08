"use strict";

const http = require("http");
const express = require("express");
const router = require("../src/routes/sessionSummary.cjs");

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

  const server = app.listen(8108, "127.0.0.1");

  try {
    const result = await postJson(8108, "/game/session-summary", {
      player: "Maya",
      attempts: [
        { player: "Maya", date: "2026-03-01", ok: true, points: 10 }
      ],
      scoreboardEntries: [
        { player: "Omar", points: 50 },
        { player: "Maya", points: 10 }
      ]
    });

    assert(result.statusCode === 200, "expected 200");
    assert(result.body.ok === true, "expected ok=true");
    assert(result.body.result.player === "Maya", "expected player Maya");
    assert(result.body.result.ready === true, "expected ready true");
    assert(result.body.result.sessionActive === true, "expected active");
    assert(result.body.result.leaderboardRank === 2, "expected rank=2");
    assert(result.body.result.totalPoints === 10, "expected totalPoints=10");

    console.log("OK ROUTE SESSION SUMMARY SMOKE PASSED");
  } finally {
    await new Promise(resolve => server.close(resolve));
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
