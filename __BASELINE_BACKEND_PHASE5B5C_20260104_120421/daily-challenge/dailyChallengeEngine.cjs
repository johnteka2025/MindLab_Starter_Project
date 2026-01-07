/**
 * Daily Challenge backend core logic (CommonJS).
 */

const BAND_CONFIG = {
  A: { band: "A", puzzleCount: 3 },
  B: { band: "B", puzzleCount: 4 },
  C: { band: "C", puzzleCount: 5 },
};

function getTodayKey(date = new Date()) {
  const y = date.getUTCFullYear();
  const m = String(date.getUTCMonth() + 1).padStart(2, "0");
  const d = String(date.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function generateDailyChallengeId(userKey, dateKey) {
  return `${userKey}:${dateKey}`;
}

function createDailyChallengeInstance(userKey, band, dateKey, puzzles) {
  const total = puzzles.length;
  const id = generateDailyChallengeId(userKey, dateKey);

  return {
    dailyChallengeId: id,
    band,
    challengeDate: dateKey,
    totalPuzzles: total,
    completedCount: 0,
    status: total > 0 ? "not_started" : "completed",
    puzzles,
  };
}

function deriveStatus(instance, streakCount) {
  return {
    status: instance.status,
    streakCount,
    puzzlesCompletedToday: instance.completedCount,
    totalPuzzlesForToday: instance.totalPuzzles,
    band: instance.band,
    challengeDate: instance.challengeDate,
  };
}

function applyAnswer(instance, puzzleId, correct, currentStreakCount) {
  const updated = {
    ...instance,
    puzzles: [...instance.puzzles],
  };

  if (correct) {
    if (updated.status !== "completed") {
      updated.completedCount = Math.min(
        updated.completedCount + 1,
        updated.totalPuzzles
      );
    }
  }

  if (updated.totalPuzzles > 0 && updated.completedCount >= updated.totalPuzzles) {
    updated.status = "completed";
  } else if (updated.completedCount > 0) {
    updated.status = "in_progress";
  } else {
    updated.status = "not_started";
  }

  let newStreak = currentStreakCount;

  if (instance.status !== "completed" && updated.status === "completed") {
    newStreak = currentStreakCount + 1;
  }

  return {
    instance: updated,
    correct,
    streakCount: newStreak,
  };
}

module.exports = {
  BAND_CONFIG,
  getTodayKey,
  createDailyChallengeInstance,
  deriveStatus,
  applyAnswer,
};
