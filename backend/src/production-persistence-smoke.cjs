"use strict";

const assert = require("assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { createPersistenceStore } = require("./production-persistence.cjs");
const { createProductionServer } = require("./production-server.cjs");

function listen(server) {
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", () => {
      resolve(server.address().port);
    });
  });
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

async function getJson(baseUrl, routePath) {
  const response = await fetch(`${baseUrl}${routePath}`);
  const body = await response.json();

  return {
    status: response.status,
    body
  };
}

async function runPersistenceSmoke() {
  const dataRoot = fs.mkdtempSync(path.join(os.tmpdir(), "mindlab-persistence-smoke-"));
  const store = createPersistenceStore({ dataRoot });
  store.resetAll();

  const directSession = store.appendSession({
    id: "session-direct",
    userId: "direct-user",
    ageCategory: "kids",
    startedAt: "2026-05-09T00:00:00.000Z",
    completedAt: null,
    status: "active"
  });

  assert.strictEqual(directSession.id, "session-direct");
  assert.strictEqual(store.readSessions().length, 1);

  store.appendAnswer({
    id: "answer-direct",
    sessionId: "session-direct",
    puzzleId: "puzzle-direct",
    selectedAnswer: "A",
    isCorrect: true,
    answeredAt: "2026-05-09T00:01:00.000Z"
  });
  assert.strictEqual(store.readAnswers().length, 1);

  store.appendScore({
    id: "score-direct",
    sessionId: "session-direct",
    correctCount: 1,
    totalCount: 1,
    percent: 100,
    createdAt: "2026-05-09T00:02:00.000Z"
  });
  assert.strictEqual(store.readScores().length, 1);

  const progress = store.updateProgress("direct-user", {
    ageCategory: "kids",
    completedPuzzleIds: ["puzzle-direct"]
  });
  assert.strictEqual(progress.userId, "direct-user");
  assert.deepStrictEqual(progress.completedPuzzleIds, ["puzzle-direct"]);

  const server = createProductionServer({
    persistenceStore: store
  });

  const port = await listen(server);
  const baseUrl = `http://127.0.0.1:${port}`;

  try {
    const session = await postJson(baseUrl, "/api/sessions", {
      userId: "server-user",
      ageCategory: "kids"
    });
    assert.strictEqual(session.status, 201);
    assert.strictEqual(session.body.ok, true);
    assert.strictEqual(session.body.session.userId, "server-user");

    const puzzles = await getJson(baseUrl, "/api/puzzles");
    assert.strictEqual(puzzles.status, 200);
    assert.strictEqual(puzzles.body.count, 9);

    const firstPuzzleId = puzzles.body.puzzles[0].id;

    const answer = await postJson(baseUrl, "/api/answers", {
      sessionId: session.body.session.id,
      puzzleId: firstPuzzleId,
      selectedAnswer: "A",
      isCorrect: false
    });
    assert.strictEqual(answer.status, 201);
    assert.strictEqual(answer.body.ok, true);

    const persistedSessions = store.readSessions();
    const persistedAnswers = store.readAnswers();

    assert.ok(persistedSessions.some((item) => item.userId === "server-user"));
    assert.ok(persistedAnswers.some((item) => item.puzzleId === firstPuzzleId));

    const progressResponse = await getJson(baseUrl, "/api/progress");
    assert.strictEqual(progressResponse.status, 200);
    assert.strictEqual(progressResponse.body.ok, true);

    console.log("PASS: PRODUCTION_PERSISTENCE_SMOKE_PASS");
  } finally {
    await new Promise((resolve) => server.close(resolve));
    fs.rmSync(dataRoot, { recursive: true, force: true });
  }
}

runPersistenceSmoke().catch((error) => {
  console.error("FAIL: PRODUCTION_PERSISTENCE_SMOKE_FAILED");
  console.error(error);
  process.exitCode = 1;
});

module.exports = {
  runPersistenceSmoke
};