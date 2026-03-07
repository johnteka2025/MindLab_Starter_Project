"use strict";

const http = require("http");
const express = require("express");
const dailySubmissionRouter = require("../src/routes/dailySubmission.cjs");
const { generateDailyPuzzle } = require("../src/engine/dailyPuzzle.cjs");

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
  app.use("/daily", dailySubmissionRouter);

  const server = app.listen(8093, "127.0.0.1");

  try {
    const puzzle = generateDailyPuzzle();

    const good = await postJson(8093, "/daily/submit", { answer: puzzle.answer });
    const bad = await postJson(8093, "/daily/submit", { answer: "wrong-answer" });

    assert(good.statusCode === 200, "expected 200 for correct submission");
    assert(bad.statusCode === 200, "expected 200 for wrong submission");

    assert(good.body.ok === true, "expected correct submission to pass");
    assert(good.body.points === 10, "expected 10 points for correct submission");

    assert(bad.body.ok === false, "expected wrong submission to fail");
    assert(bad.body.points === 0, "expected 0 points for wrong submission");

    assert(typeof good.body.date === "string" && good.body.date.length === 10, "invalid response date");
    assert(typeof good.body.question === "string" && good.body.question.length > 0, "invalid response question");

    console.log("OK ROUTE DAILY SUBMISSION SMOKE PASSED");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
