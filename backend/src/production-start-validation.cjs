"use strict";

const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { loadProductionRuntimeEnv } = require("./production-runtime-env.cjs");
const { createProductionServer } = require("./production-server.cjs");

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      resolve(server.address().port);
    });
  });
}

async function getJson(baseUrl, routePath) {
  const response = await fetch(`${baseUrl}${routePath}`);
  const body = await response.json();
  return {
    status: response.status,
    body
  };
}

async function postJson(baseUrl, routePath, payload) {
  const response = await fetch(`${baseUrl}${routePath}`, {
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

async function runProductionStartValidation() {
  const dataRoot = fs.mkdtempSync(path.join(os.tmpdir(), "mindlab-runtime-start-validation-"));

  const runtimeConfig = loadProductionRuntimeEnv({
    PORT: "3100",
    MINDLAB_PERSISTENCE_ENABLED: "1",
    MINDLAB_PERSISTENCE_DATA_ROOT: dataRoot,
    FRONTEND_API_BASE_URL: "http://127.0.0.1:3100"
  }, {
    requirePersistence: true
  });

  const server = createProductionServer({
    persistence: runtimeConfig.persistenceEnabled,
    dataRoot: runtimeConfig.persistenceDataRoot
  });

  const port = await listen(server);
  const baseUrl = `http://127.0.0.1:${port}`;

  try {
    const health = await getJson(baseUrl, "/api/health");
    assert.strictEqual(health.status, 200);
    assert.strictEqual(health.body.ok, true);
    assert.strictEqual(health.body.puzzleCount, 9);

    const session = await postJson(baseUrl, "/api/sessions", {
      userId: "runtime-validation-user",
      ageCategory: "kids"
    });
    assert.strictEqual(session.status, 201);
    assert.strictEqual(session.body.ok, true);

    const puzzles = await getJson(baseUrl, "/api/puzzles");
    assert.strictEqual(puzzles.status, 200);
    assert.strictEqual(puzzles.body.count, 9);

    const answer = await postJson(baseUrl, "/api/answers", {
      sessionId: session.body.session.id,
      puzzleId: puzzles.body.puzzles[0].id,
      selectedAnswer: "A",
      isCorrect: false
    });
    assert.strictEqual(answer.status, 201);
    assert.strictEqual(answer.body.ok, true);

    assert.strictEqual(fs.existsSync(path.join(dataRoot, "sessions.json")), true);
    assert.strictEqual(fs.existsSync(path.join(dataRoot, "answers.json")), true);
    assert.strictEqual(fs.existsSync(path.join(dataRoot, "scores.json")), true);
    assert.strictEqual(fs.existsSync(path.join(dataRoot, "progress.json")), true);

    console.log("PASS: PRODUCTION_RUNTIME_START_VALIDATION_PASS");
  } finally {
    await new Promise((resolve) => server.close(resolve));
    fs.rmSync(dataRoot, { recursive: true, force: true });
  }
}

runProductionStartValidation().catch((error) => {
  console.error("FAIL: PRODUCTION_RUNTIME_START_VALIDATION_FAILED");
  console.error(error);
  process.exitCode = 1;
});

module.exports = {
  runProductionStartValidation
};