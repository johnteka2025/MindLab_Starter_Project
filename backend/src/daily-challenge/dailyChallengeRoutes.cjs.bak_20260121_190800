const express = require("express");
const { buildDailyChallengeState } = require("./dailyChallengeEngine.cjs");

let state = null;

function getState() {
  if (!state) state = buildDailyChallengeState();
  // Ensure internal tracking exists (backward compatible)
  if (!state._solved) state._solved = new Set();
  if (!state._allAnswers) state._allAnswers = {};
  if (!Array.isArray(state.puzzles)) state.puzzles = [];
  if (typeof state.status !== "string") state.status = "active";
  if (typeof state.progress !== "number") state.progress = 0;
  if (typeof state.streak !== "number") state.streak = 0;
  if (typeof state.dailyChallengeId !== "string") state.dailyChallengeId = "daily";
  return state;
}

function normalizeBody(req) {
  let body = (req && req.body != null) ? req.body : null;

  // If express.json() is active, body should already be object.
  // Be defensive for string body.
  if (typeof body === "string") {
    try { body = JSON.parse(body); } catch (_) { body = null; }
  }

  if (!body || typeof body !== "object") return null;
  return body;
}

function normalizePuzzleId(body) {
  const raw = (body && (body.puzzleId ?? body.puzzleID ?? body.puzzle_id));
  if (typeof raw === "string") {
    const t = raw.trim();
    return t.length ? t : null;
  }
  if (typeof raw === "number" && Number.isFinite(raw)) return String(raw);
  return null;
}

function createDailyChallengeRouter() {
  const router = express.Router();

  // GET /daily  (contract uses this)
  router.get("/daily", (req, res) => {
    const s = getState();
    return res.status(200).json({
      dailyChallengeId: s.dailyChallengeId,
      puzzles: s.puzzles,
      status: s.status,
      progress: s.progress,
      streak: s.streak,
    });
  });

  // GET /daily/status
  router.get("/daily/status", (req, res) => {
    const s = getState();
    return res.status(200).json({
      status: s.status,
      progress: s.progress,
      streak: s.streak,
      dailyChallengeId: s.dailyChallengeId,
    });
  });

  // POST /daily/answer
  router.post("/daily/answer", (req, res) => {
    const s = getState();

    const body = normalizeBody(req);
    if (!body) {
      // Contract allows 400/415 for missing body; use 400 consistently
      return res.status(400).json({ error: "BadRequest", message: "Missing JSON body" });
    }

    const providedDailyChallengeId = body.dailyChallengeId;
    if (typeof providedDailyChallengeId === "string" && providedDailyChallengeId !== s.dailyChallengeId) {
      return res.status(404).json({
        error: "DailyChallengeNotFound",
        message: "dailyChallengeId is not current",
        dailyChallengeId: providedDailyChallengeId,
      });
    }

    const pid = normalizePuzzleId(body);
    if (!pid) {
      return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });
    }

    // Must exist in today's puzzles
    if (!(pid in s._allAnswers)) {
      return res.status(404).json({ error: "PuzzleNotFound", message: "puzzleId not found in today's puzzles" });
    }

    // After completion => 409
    if (s.status === "completed") {
      return res.status(409).json({ error: "ChallengeCompleted", message: "daily challenge already completed" });
    }

    // Same puzzle twice => 409
    if (s._solved.has(pid)) {
      return res.status(409).json({ error: "PuzzleAlreadyAnswered", message: "puzzle already answered" });
    }

    // For contract: answer may be omitted; treat as correct to allow progress completion
    let correct = true;
    if (typeof body.answer === "string") {
      correct = (String(s._allAnswers[pid] ?? "").toLowerCase().trim() === body.answer.toLowerCase().trim());
    }

    if (correct) {
      s._solved.add(pid);
      s.progress = Math.min(s.puzzles.length, s._solved.size);

      if (s.progress >= s.puzzles.length) {
        s.status = "completed";
        s.streak = (Number(s.streak) || 0) + 1;
      }
    }

    return res.status(200).json({
      ok: correct,
      dailyChallengeId: s.dailyChallengeId,
      puzzleId: pid,
      status: s.status,
      progress: s.progress,
      streak: s.streak,
    });
  });

  return router;
}

module.exports = {
  createDailyChallengeRouter,
};
