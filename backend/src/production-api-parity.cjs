"use strict";

const assert = require("assert");
const { productionApiContract } = require("./production-api-contract.cjs");
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

async function runParity() {
  const requiredRoutes = [
    "health",
    "puzzles",
    "puzzleById",
    "seedPuzzles",
    "sessions",
    "answers",
    "progress"
  ];

  for (const routeName of requiredRoutes) {
    assert.ok(productionApiContract.routes[routeName], `MISSING_CONTRACT_ROUTE_${routeName}`);
  }

  const server = createProductionServer();
  const port = await listen(server);
  const baseUrl = `http://127.0.0.1:${port}`;

  try {
    const health = await getJson(baseUrl, productionApiContract.routes.health);
    assert.strictEqual(health.status, 200);
    assert.strictEqual(health.body.ok, true);
    assert.strictEqual(health.body.service, "mindlab-production-backend");
    assert.strictEqual(health.body.puzzleCount, 9);

    const puzzles = await getJson(baseUrl, productionApiContract.routes.puzzles);
    assert.strictEqual(puzzles.status, 200);
    assert.strictEqual(puzzles.body.ok, true);
    assert.strictEqual(puzzles.body.count, 9);
    assert.ok(Array.isArray(puzzles.body.puzzles));

    const seed = await getJson(baseUrl, productionApiContract.routes.seedPuzzles);
    assert.strictEqual(seed.status, 200);
    assert.strictEqual(seed.body.ok, true);
    assert.strictEqual(seed.body.seed.puzzles.length, 9);

    const firstPuzzleId = puzzles.body.puzzles[0].id;
    assert.ok(firstPuzzleId);

    const puzzleRoute = productionApiContract.routes.puzzleById.replace(":id", encodeURIComponent(firstPuzzleId));
    const puzzleById = await getJson(baseUrl, puzzleRoute);
    assert.strictEqual(puzzleById.status, 200);
    assert.strictEqual(puzzleById.body.ok, true);
    assert.strictEqual(puzzleById.body.puzzle.id, firstPuzzleId);

    const session = await postJson(baseUrl, productionApiContract.routes.sessions, {
      userId: "parity-user",
      ageCategory: "kids"
    });
    assert.strictEqual(session.status, 201);
    assert.strictEqual(session.body.ok, true);
    assert.strictEqual(session.body.session.userId, "parity-user");

    const answer = await postJson(baseUrl, productionApiContract.routes.answers, {
      sessionId: session.body.session.id,
      puzzleId: firstPuzzleId,
      selectedAnswer: "A",
      isCorrect: false
    });
    assert.strictEqual(answer.status, 201);
    assert.strictEqual(answer.body.ok, true);
    assert.strictEqual(answer.body.answer.puzzleId, firstPuzzleId);

    const progress = await getJson(baseUrl, productionApiContract.routes.progress);
    assert.strictEqual(progress.status, 200);
    assert.strictEqual(progress.body.ok, true);

    console.log("PASS: PRODUCTION_BACKEND_API_PARITY_PASS");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

runParity().catch((error) => {
  console.error("FAIL: PRODUCTION_BACKEND_API_PARITY_FAILED");
  console.error(error);
  process.exitCode = 1;
});