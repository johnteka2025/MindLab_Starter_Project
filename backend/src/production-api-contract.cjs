"use strict";

const productionApiContract = Object.freeze({
  version: "v1",
  source: "production-backend-migration-plan",
  routes: Object.freeze({
    health: "/api/health",
    puzzles: "/api/puzzles",
    puzzleById: "/api/puzzles/:id",
    seedPuzzles: "/api/puzzles/seed",
    sessions: "/api/sessions",
    sessionById: "/api/sessions/:id",
    answers: "/api/answers",
    scores: "/api/scores",
    progress: "/api/progress"
  }),
  entities: Object.freeze({
    puzzle: Object.freeze(["id", "ageCategory", "title", "prompt", "choices", "answer", "explanation"]),
    user: Object.freeze(["id", "displayName", "ageCategory", "createdAt", "updatedAt"]),
    session: Object.freeze(["id", "userId", "ageCategory", "startedAt", "completedAt", "status"]),
    answer: Object.freeze(["id", "sessionId", "puzzleId", "selectedAnswer", "isCorrect", "answeredAt"]),
    score: Object.freeze(["id", "sessionId", "correctCount", "totalCount", "percent", "createdAt"]),
    progress: Object.freeze(["userId", "ageCategory", "completedPuzzleIds", "lastUpdatedAt"])
  }),
  compatibility: Object.freeze({
    qaServerSource: "backend/src/qa-server.cjs",
    seedJsonSource: "content/seed-puzzles/mindlab-seed-puzzles.v1.json",
    firstImplementationMode: "route-compatible-production-backend"
  })
});

function getProductionApiContract() {
  return productionApiContract;
}

module.exports = {
  productionApiContract,
  getProductionApiContract
};
