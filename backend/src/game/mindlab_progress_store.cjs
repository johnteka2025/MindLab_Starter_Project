const fs = require("fs");
const path = require("path");

const progressPath = path.join(__dirname, "..", "data", "progress.json");

function ensureSeed() {
  if (!fs.existsSync(progressPath)) {
    fs.mkdirSync(path.dirname(progressPath), { recursive: true });
    fs.writeFileSync(progressPath, JSON.stringify({}, null, 2), "utf8");
  }
}

function loadAllProgress() {
  ensureSeed();
  const raw = fs.readFileSync(progressPath, "utf8");
  return raw ? JSON.parse(raw) : {};
}

function saveAllProgress(all) {
  fs.writeFileSync(progressPath, JSON.stringify(all, null, 2), "utf8");
}

function getUserProgress(userId) {
  const all = loadAllProgress();
  return all[userId] || {
    userId,
    totalScore: 0,
    solved: 0,
    failed: 0,
    streak: 0,
    lastPuzzleId: null,
    updatedAt: null
  };
}

function saveUserProgress(progress) {
  const all = loadAllProgress();
  all[progress.userId] = progress;
  saveAllProgress(all);
  return progress;
}

module.exports = { loadAllProgress, getUserProgress, saveUserProgress };