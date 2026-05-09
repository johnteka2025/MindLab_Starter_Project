"use strict";

const assert = require("assert");
const { productionApiContract } = require("./production-api-contract.cjs");
const { createProductionServer } = require("./production-server.cjs");

function normalizeApiBaseUrl(value) {
  const raw = String(value || "").trim();

  if (!raw) {
    throw new Error("MISSING_FRONTEND_API_BASE_URL");
  }

  return raw.replace(/\/+$/, "");
}

function buildApiUrl(baseUrl, routePath) {
  if (!routePath || !routePath.startsWith("/")) {
    throw new Error(`INVALID_ROUTE_PATH :: ${routePath}`);
  }

  return `${normalizeApiBaseUrl(baseUrl)}${routePath}`;
}

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      resolve(server.address().port);
    });
  });
}

async function getJson(baseUrl, routePath) {
  const response = await fetch(buildApiUrl(baseUrl, routePath));
  const body = await response.json();
  return {
    status: response.status,
    body
  };
}

async function postJson(baseUrl, routePath, payload) {
  const response = await fetch(buildApiUrl(baseUrl, routePath), {
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

async function runFrontendSwitchValidation() {
  const server = createProductionServer();
  const port = await listen(server);
  const frontendApiBaseUrl = `http://127.0.0.1:${port}`;

  try {
    const requiredFrontendRoutes = [
      "health",
      "puzzles",
      "puzzleById",
      "seedPuzzles",
      "sessions",
      "answers",
      "progress"
    ];

    for (const routeName of requiredFrontendRoutes) {
      assert.ok(productionApiContract.routes[routeName], `MISSING_FRONTEND_ROUTE_CONTRACT_${routeName}`);
    }

    assert.strictEqual(normalizeApiBaseUrl(`${frontendApiBaseUrl}/`), frontendApiBaseUrl);
    assert.strictEqual(buildApiUrl(frontendApiBaseUrl, productionApiContract.routes.health), `${frontendApiBaseUrl}/api/health`);

    const health = await getJson(frontendApiBaseUrl, productionApiContract.routes.health);
    assert.strictEqual(health.status, 200);
    assert.strictEqual(health.body.ok, true);
    assert.strictEqual(health.body.service, "mindlab-production-backend");

    const puzzles = await getJson(frontendApiBaseUrl, productionApiContract.routes.puzzles);
    assert.strictEqual(puzzles.status, 200);
    assert.strictEqual(puzzles.body.ok, true);
    assert.strictEqual(puzzles.body.count, 9);
    assert.ok(Array.isArray(puzzles.body.puzzles));

    const seed = await getJson(frontendApiBaseUrl, productionApiContract.routes.seedPuzzles);
    assert.strictEqual(seed.status, 200);
    assert.strictEqual(seed.body.ok, true);
    assert.strictEqual(seed.body.seed.puzzles.length, 9);

    const firstPuzzleId = puzzles.body.puzzles[0].id;
    assert.ok(firstPuzzleId);

    const puzzleRoute = productionApiContract.routes.puzzleById.replace(":id", encodeURIComponent(firstPuzzleId));
    const puzzleById = await getJson(frontendApiBaseUrl, puzzleRoute);
    assert.strictEqual(puzzleById.status, 200);
    assert.strictEqual(puzzleById.body.ok, true);
    assert.strictEqual(puzzleById.body.puzzle.id, firstPuzzleId);

    const session = await postJson(frontendApiBaseUrl, productionApiContract.routes.sessions, {
      userId: "frontend-switch-user",
      ageCategory: "kids"
    });
    assert.strictEqual(session.status, 201);
    assert.strictEqual(session.body.ok, true);
    assert.strictEqual(session.body.session.userId, "frontend-switch-user");

    const answer = await postJson(frontendApiBaseUrl, productionApiContract.routes.answers, {
      sessionId: session.body.session.id,
      puzzleId: firstPuzzleId,
      selectedAnswer: "A",
      isCorrect: false
    });
    assert.strictEqual(answer.status, 201);
    assert.strictEqual(answer.body.ok, true);
    assert.strictEqual(answer.body.answer.puzzleId, firstPuzzleId);

    const progress = await getJson(frontendApiBaseUrl, productionApiContract.routes.progress);
    assert.strictEqual(progress.status, 200);
    assert.strictEqual(progress.body.ok, true);

    console.log("PASS: FRONTEND_PRODUCTION_BACKEND_SWITCH_VALIDATION_PASS");
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

runFrontendSwitchValidation().catch((error) => {
  console.error("FAIL: FRONTEND_PRODUCTION_BACKEND_SWITCH_VALIDATION_FAILED");
  console.error(error);
  process.exitCode = 1;
});

module.exports = {
  buildApiUrl,
  normalizeApiBaseUrl,
  runFrontendSwitchValidation
};