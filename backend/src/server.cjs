const { getUserProgress, saveUserProgress } = require("./game/mindlab_progress_store.cjs");
const ScoringRules = require("./game/mindlab_scoring_rules.cjs");

function resolveScoringFunction(moduleRef, names) {
  const candidates = [];
  if (moduleRef) candidates.push(moduleRef);
  if (moduleRef && moduleRef.default) candidates.push(moduleRef.default);

  for (const candidate of candidates) {
    for (const name of names) {
      if (typeof candidate[name] === "function") return candidate[name];
    }
  }

  return null;
}

const normalizeScorePayloadFn =
  resolveScoringFunction(ScoringRules, [
    "normalizeScorePayload",
    "normalizePayload",
    "normalizeMindLabScorePayload",
    "normalizeMindLabPayload"
  ]) ||
  ((payload) => payload || {});

const calculateScoreFn =
  resolveScoringFunction(ScoringRules, [
    "calculateScore",
    "scoreSubmission",
    "calculateMindLabScore",
    "calculateMindLabSubmissionScore"
  ]) ||
  ((payload) => ({
    earned: payload && payload.isCorrect ? Number(payload.basePoints || 0) : 0
  }));
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 8085;

app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.get("/health", (req, res) => {
  res.status(200).json({
    ok: true,
    status: "ok",
    port: PORT
  });
});




// PHASE18_ROUTE_MOUNT_START
require("./puzzlesRoutes.cjs")(app);
require("./progressRoutes.cjs")(app);
// PHASE18_ROUTE_MOUNT_END
app.post("/score", (req, res) => {
  try {
    if (typeof normalizeScorePayloadFn !== "function" || typeof calculateScoreFn !== "function") {
      throw new Error("Scoring rule functions are missing");
    }
    const payload = normalizeScorePayloadFn(req.body || {});
    const result = calculateScoreFn(payload);
    const current = getUserProgress(payload.userId);

    const next = {
      userId: payload.userId,
      totalScore: Number(current.totalScore || 0) + Number(result.earned || 0),
      solved: Number(current.solved || 0) + (payload.isCorrect ? 1 : 0),
      failed: Number(current.failed || 0) + (payload.isCorrect ? 0 : 1),
      streak: payload.isCorrect ? Number(payload.streak || 0) : 0,
      lastPuzzleId: payload.puzzleId,
      updatedAt: new Date().toISOString()
    };

    saveUserProgress(next);

    return res.status(200).json({
      ok: true,
      result,
      progress: next
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      error: error.message
    });
  }
});

app.get("/progress/:userId", (req, res) => {
  try {
    const progress = getUserProgress(req.params.userId);
    return res.status(200).json({ ok: true, progress });
  } catch (error) {
    return res.status(500).json({ ok: false, error: error.message });
  }
});
app.use((req, res) => {
  res.status(404).json({
    ok: false,
    error: `Route not found: ${req.method} ${req.originalUrl}`
  });
});

app.use((error, req, res, next) => {
  res.status(400).json({
    ok: false,
    error: "Invalid JSON body"
  });
});





app.listen(PORT, () => {
  console.log(`MindLab backend listening on ${PORT}`);
});
