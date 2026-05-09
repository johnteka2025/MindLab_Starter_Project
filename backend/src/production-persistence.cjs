"use strict";

const fs = require("fs");
const path = require("path");

const DEFAULT_DATA_ROOT = path.resolve(__dirname, "data");

const DEFAULT_FILES = Object.freeze({
  sessions: "sessions.json",
  answers: "answers.json",
  scores: "scores.json",
  progress: "progress.json"
});

function stripUtf8Bom(raw) {
  if (typeof raw !== "string") {
    return raw;
  }

  return raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw;
}

function ensureDirectory(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
  return dirPath;
}

function resolveStorePath(dataRoot, name) {
  const fileName = DEFAULT_FILES[name];

  if (!fileName) {
    throw new Error(`UNKNOWN_PERSISTENCE_FILE :: ${name}`);
  }

  return path.join(dataRoot, fileName);
}

function readJsonFile(filePath, fallbackValue) {
  if (!fs.existsSync(filePath)) {
    return fallbackValue;
  }

  const raw = fs.readFileSync(filePath, "utf8");
  const normalized = stripUtf8Bom(raw).trim();

  if (!normalized) {
    return fallbackValue;
  }

  return JSON.parse(normalized);
}

function writeJsonFileAtomic(filePath, value) {
  ensureDirectory(path.dirname(filePath));

  const tempPath = `${filePath}.${process.pid}.${Date.now()}.tmp`;
  fs.writeFileSync(tempPath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
  fs.renameSync(tempPath, filePath);

  return value;
}

function ensureJsonFile(filePath, fallbackValue) {
  if (!fs.existsSync(filePath)) {
    writeJsonFileAtomic(filePath, fallbackValue);
  }

  return readJsonFile(filePath, fallbackValue);
}

function createPersistenceStore(options = {}) {
  const dataRoot = path.resolve(options.dataRoot || DEFAULT_DATA_ROOT);
  ensureDirectory(dataRoot);

  const paths = Object.freeze({
    sessions: resolveStorePath(dataRoot, "sessions"),
    answers: resolveStorePath(dataRoot, "answers"),
    scores: resolveStorePath(dataRoot, "scores"),
    progress: resolveStorePath(dataRoot, "progress")
  });

  function ensureAllFiles() {
    ensureJsonFile(paths.sessions, []);
    ensureJsonFile(paths.answers, []);
    ensureJsonFile(paths.scores, []);
    ensureJsonFile(paths.progress, {});
    return true;
  }

  function readSessions() {
    return readJsonFile(paths.sessions, []);
  }

  function readAnswers() {
    return readJsonFile(paths.answers, []);
  }

  function readScores() {
    return readJsonFile(paths.scores, []);
  }

  function readProgress() {
    return readJsonFile(paths.progress, {});
  }

  function writeSessions(items) {
    if (!Array.isArray(items)) {
      throw new Error("SESSIONS_MUST_BE_ARRAY");
    }

    return writeJsonFileAtomic(paths.sessions, items);
  }

  function writeAnswers(items) {
    if (!Array.isArray(items)) {
      throw new Error("ANSWERS_MUST_BE_ARRAY");
    }

    return writeJsonFileAtomic(paths.answers, items);
  }

  function writeScores(items) {
    if (!Array.isArray(items)) {
      throw new Error("SCORES_MUST_BE_ARRAY");
    }

    return writeJsonFileAtomic(paths.scores, items);
  }

  function writeProgress(progress) {
    if (!progress || typeof progress !== "object" || Array.isArray(progress)) {
      throw new Error("PROGRESS_MUST_BE_OBJECT");
    }

    return writeJsonFileAtomic(paths.progress, progress);
  }

  function appendSession(session) {
    const sessions = readSessions();
    sessions.push(session);
    writeSessions(sessions);
    return session;
  }

  function appendAnswer(answer) {
    const answers = readAnswers();
    answers.push(answer);
    writeAnswers(answers);
    return answer;
  }

  function appendScore(score) {
    const scores = readScores();
    scores.push(score);
    writeScores(scores);
    return score;
  }

  function updateProgress(userId, patch) {
    if (!userId) {
      throw new Error("PROGRESS_USER_ID_REQUIRED");
    }

    const progress = readProgress();
    const current = progress[userId] || {
      userId,
      completedPuzzleIds: [],
      lastUpdatedAt: null
    };

    progress[userId] = {
      ...current,
      ...patch,
      userId,
      lastUpdatedAt: new Date().toISOString()
    };

    writeProgress(progress);
    return progress[userId];
  }

  function getState() {
    ensureAllFiles();

    return {
      sessions: readSessions(),
      answers: readAnswers(),
      scores: readScores(),
      progress: readProgress()
    };
  }

  function resetAll() {
    writeSessions([]);
    writeAnswers([]);
    writeScores([]);
    writeProgress({});
    return getState();
  }

  ensureAllFiles();

  return Object.freeze({
    dataRoot,
    paths,
    appendAnswer,
    appendScore,
    appendSession,
    ensureAllFiles,
    getState,
    readAnswers,
    readProgress,
    readScores,
    readSessions,
    resetAll,
    updateProgress,
    writeAnswers,
    writeProgress,
    writeScores,
    writeSessions
  });
}

module.exports = {
  DEFAULT_DATA_ROOT,
  DEFAULT_FILES,
  createPersistenceStore,
  ensureDirectory,
  readJsonFile,
  stripUtf8Bom,
  writeJsonFileAtomic
};