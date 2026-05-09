"use strict";

const assert = require("assert");
const { createProductionServer } = require("./production-server.cjs");

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      resolve(server.address().port);
    });
  });
}

async function getJson(baseUrl, pathName) {
  const response = await fetch(`${baseUrl}${pathName}`);
  const body = await response.json();
  return {
    status: response.status,
    body
  };
}

async function postJson(baseUrl, pathName, payload) {
  const response = await fetch(`${baseUrl}${pathName}`, {
    method: "POST",
    headers: {
      "content-type": "application/json"
    },
    body: JSON.stringify(payload)
  });
  const body = await response.json();
  return {
    status: response.status,
    body
  };
}

async function runSmoke() {
  const server = createProductionServer();
  const port = await listen(server);
  const baseUrl = `http://127.0.0.1:${port}`;

  try {
    const health = await getJson(baseUrl, "/api/health");
    assert.strictEqual(health.status, 200);
    assert.strictEqual(health.body.ok, true);
    assert.strictEqual(health.body.puzzleCount, 9);

    const puzzles = await getJson(baseUrl, "/api/puzzles");
    assert.strictEqual(puzzles.status, 200);
    assert.strictEqual(puzzles.body.ok, true);
    assert.strictEqual(puzzles.body.count, 9);
    assert.ok(Array.isArray(puzzles.body.puzzles));

    const firstPuzzleId = puzzles.body.puzzles[0].id;
    assert.ok(firstPuzzleId);

    const puzzleById = await getJson(baseUrl, `/api/puzzles/${encodeURIComponent(firstPuzzleId)}`);
    assert.strictEqual(puzzleById.status, 200);
    assert.strictEqual(puzzleById.body.ok, true);
    assert.strictEqual(puzzleById.body.puzzle.id, firstPuzzleId);

    const missingPuzzle = await getJson(baseUrl, "/api/puzzles/not-a-real-id");
    assert.strictEqual(missingPuzzle.status, 404);
    assert.strictEqual(missingPuzzle.body.ok, false);

    const session = await postJson(baseUrl, "/api/sessions", {
      userId: "smoke-user",
      ageCategory: "kids"
    });
    assert.strictEqual(session.status, 201);
    assert.strictEqual(session.body.ok, true);
    assert.strictEqual(session.body.session.userId, "smoke-user");

    const answer = await postJson(baseUrl, "/api/answers", {
      sessionId: session.body.session.id,
      puzzleId: firstPuzzleId,
      selectedAnswer: "A",
      isCorrect: false
    });
    assert.strictEqual(answer.status, 201);
    assert.strictEqual(answer.body.ok, true);
    assert.strictEqual(answer.body.answer.puzzleId, firstPuzzleId);

    const progress = await getJson(baseUrl, "/api/progress");
    assert.strictEqual(progress.status, 200);
    assert.strictEqual(progress.body.ok, true);

    console.log("PASS: ROUTE_COMPATIBLE_PRODUCTION_BACKEND_SMOKE_PASS");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

runSmoke().catch((error) => {
  console.error("FAIL: ROUTE_COMPATIBLE_PRODUCTION_BACKEND_SMOKE_FAILED");
  console.error(error);
  process.exitCode = 1;
});