const express = require("express");
const {
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
} = require("./dailyChallengeEngine.cjs");

/**
 * In-memory store for Daily Challenge state.
 * For production, replace with database storage.
 */

// userKey -> { instanceByDate: { [dateKey]: instance }, streakCount: number }
const userStore = {};

function getUserKey(req) {
  // Later this can come from auth/session.
  return "demo-user";
}

function getBandForUser(req) {
  // Later this could be user preference or difficulty level.
  return "B";
}

function getOrCreateUserState(userKey) {
  let state = userStore[userKey];
  if (!state) {
    state = { instanceByDate: {}, streakCount: 0 };
    userStore[userKey] = state;
  }
  return state;
}

function generatePuzzlesForBand(band, dateKey) {
  const config = BAND_CONFIG[band] || BAND_CONFIG["B"];
  const count = config.puzzleCount;
  const puzzles = [];

  for (let i = 1; i <= count; i++) {
    puzzles.push({
      id: ${dateKey}--,
      title: Daily Puzzle ,
      type: "demo",
      difficulty: i,
    });
  }

  return puzzles;
}

function getOrCreateInstanceForToday(userKey, band, dateKey) {
  const state = getOrCreateUserState(userKey);
  let instance = state.instanceByDate[dateKey];

  if (!instance) {
    const puzzles = generatePuzzlesForBand(band, dateKey);
    instance = createDailyChallengeInstance(userKey, band, dateKey, puzzles);
    state.instanceByDate[dateKey] = instance;
  }

  return { state, instance };
}

function createDailyChallengeRouter() {
  const router = express.Router();

  // GET /daily/status
  router.get("/daily/status", (req, res) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    const status = deriveStatus(instance, state.streakCount);
    return res.status(200).json(status);
  });

  // GET /daily
  router.get("/daily", (req, res) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    // state currently unused here, but kept for symmetry.
    void state;

    return res.status(200).json(instance);
  });

  // POST /daily/answer
  router.post("/daily/answer", (req, res) => {
    const userKey = getUserKey(req);
    const band = getBandForUser(req);
    const dateKey = getTodayKey();

    const { state, instance } = getOrCreateInstanceForToday(
      userKey,
      band,
      dateKey
    );

    const body = req.body || {};
    const dailyChallengeId = body.dailyChallengeId;
    const puzzleId = body.puzzleId;

    if (!puzzleId) {
      return res.status(400).json({
        error: "ValidationError",
        message: "puzzleId is required",
      });
    }

    if (dailyChallengeId && dailyChallengeId !== instance.dailyChallengeId) {
      return res.status(400).json({
        error: "DailyChallengeNotFound",
        message: "dailyChallengeId does not match today's challenge",
      });
    }

    // For now, treat all answers as correct.
    const correct = true;

    const result = applyAnswer(
      instance,
      puzzleId,
      correct,
      state.streakCount
    );

    // Save updated instance & streak
    state.instanceByDate[dateKey] = result.instance;
    state.streakCount = result.streakCount;

    return res.status(200).json({
      dailyChallengeId: result.instance.dailyChallengeId,
      puzzleId,
      correct: result.correct,
      completedCount: result.instance.completedCount,
      totalPuzzles: result.instance.totalPuzzles,
      status: result.instance.status,
      streakCount: result.streakCount,
    });
  });

  return router;
}

module.exports = {
  createDailyChallengeRouter,
};
