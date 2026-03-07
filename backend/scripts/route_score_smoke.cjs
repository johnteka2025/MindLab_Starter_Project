"use strict";

const http = require("http");
const express = require("express");
const scoreRouter = require("../src/routes/score.cjs");

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
  app.use("/game", scoreRouter);

  const server = app.listen(8092, "127.0.0.1");

  try {
    const correct = await postJson(8092, "/game/score", { isCorrect: true });
    const wrong = await postJson(8092, "/game/score", { isCorrect: false });

    assert(correct.statusCode === 200, "expected 200 for correct score request");
    assert(wrong.statusCode === 200, "expected 200 for wrong score request");

    assert(correct.body.ok === true, "expected ok=true for correct answer");
    assert(correct.body.points === 10, "expected 10 points for correct answer");

    assert(wrong.body.ok === false, "expected ok=false for wrong answer");
    assert(wrong.body.points === 0, "expected 0 points for wrong answer");

    console.log("OK ROUTE SCORE SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
