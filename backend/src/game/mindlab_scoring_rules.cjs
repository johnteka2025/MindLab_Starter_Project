const fs = require("fs");
const path = require("path");

const PROGRESS_FILE = path.join(__dirname, "..", "data", "progress.json");

function loadMindLabProgress() {
  if (!fs.existsSync(PROGRESS_FILE)) {
    return {};
  }

  const raw = fs.readFileSync(PROGRESS_FILE, "utf8").trim();
  if (!raw) {
    return {};
  }

  return JSON.parse(raw);
}

function saveMindLabProgress(progress) {
  fs.writeFileSync(PROGRESS_FILE, JSON.stringify(progress, null, 2), "utf8");
  return progress;
}

function calculateMindLabScore(payload = {}) {
  const scoreDelta = Number(payload.scoreDelta ?? 0);
  const result = String(payload.result ?? "unknown");
  const normalized = Number.isFinite(scoreDelta) ? scoreDelta : 0;

  let awarded = normalized;

  if (result === "correct" && awarded <= 0) awarded = 1;
  if (result === "incorrect" && awarded > 0) awarded = 0;

  return {
    sessionId: payload.sessionId ?? "default-session",
    puzzleId: payload.puzzleId ?? null,
    awardedScore: awarded,
    result,
    metadata: payload.metadata ?? {}
  };
}

function applyMindLabScore(progress = {}, scoreRecord = {}) {
  const sessionId = scoreRecord.sessionId ?? "default-session";

  if (!progress[sessionId]) {
    progress[sessionId] = {
      totalScore: 0,
      completedPuzzles: [],
      lastResult: null
    };
  }

  progress[sessionId].totalScore += Number(scoreRecord.awardedScore ?? 0);

  if (scoreRecord.puzzleId && !progress[sessionId].completedPuzzles.includes(scoreRecord.puzzleId)) {
    progress[sessionId].completedPuzzles.push(scoreRecord.puzzleId);
  }

  progress[sessionId].lastResult = scoreRecord.result ?? null;
  return progress;
}

module.exports = {
  PROGRESS_FILE,
  loadMindLabProgress,
  saveMindLabProgress,
  calculateMindLabScore,
  applyMindLabScore
};
