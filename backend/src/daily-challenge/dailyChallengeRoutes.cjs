"use strict";

const express = require("express");

// UTC key
function utcDateKey(d = new Date()) {
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, "0");
  const day = String(d.getUTCDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}
function makeDailyId(key) { return `daily-${key}`; }

let currentKey = null;
let streak = 0;
let state = null;

function ensureState() {
  const key = utcDateKey();
  if (currentKey !== key || !state) {
    currentKey = key;
    state = {
      dailyChallengeId: makeDailyId(key),
      puzzles: [
        { id: 1, question: "Puzzle 1" },
        { id: 2, question: "Puzzle 2" },
        { id: 3, question: "Puzzle 3" },
      ],
      expected: { "1": "a", "2": "b", "3": "c" },
      answered: new Set(),
      solved: new Set(),
      status: "not_started",
      progress: 0,
    };
  }
  return state;
}

function normalizeBody(req) {
  let body = (req && req.body != null) ? req.body : null;
  if (typeof body === "string") {
    try { body = JSON.parse(body); } catch (_) { body = null; }
  }
  if (!body || typeof body !== "object") return null;
  return body;
}

function pickPuzzleId(body) {
  const raw = (body && (body.puzzleId ?? body.puzzleID ?? body.puzzle_id)) ?? null;
  if (raw == null) return null;
  if (typeof raw === "number" && Number.isFinite(raw)) return String(raw);
  if (typeof raw === "string" && raw.trim().length > 0) return raw.trim();
  return null;
}

function pickDailyId(body) {
  const raw = (body && (body.dailyChallengeId ?? body.dailyChallengeID ?? body.daily_challenge_id)) ?? null;
  if (raw == null) return null;
  if (typeof raw === "string" && raw.trim().length > 0) return raw.trim();
  if (typeof raw === "number" && Number.isFinite(raw)) return String(raw);
  return null;
}

function pickAnswer(body) {
  const raw = (body && (body.answer ?? body.ans ?? body.response)) ?? undefined;
  if (raw == null) return undefined;
  if (typeof raw === "number" && Number.isFinite(raw)) return String(raw);
  if (typeof raw === "string") return raw;
  return String(raw);
}

function createDailyChallengeRouter() {
  const router = express.Router();

  router.get("/daily", (req, res) => {
    const s = ensureState();
    return res.status(200).json({
      dailyChallengeId: s.dailyChallengeId,
      puzzles: s.puzzles,
    });
  });

  router.get("/daily/status", (req, res) => {
    const s = ensureState();
    return res.status(200).json({
      status: s.status,
      progress: s.progress,
      streak: streak,
      dailyChallengeId: s.dailyChallengeId,
    });
  });

  router.post("/daily/answer", (req, res) => {
    const s = ensureState();

    const body = normalizeBody(req);
    if (!body) return res.status(400).json({ error: "BadRequest", message: "Missing JSON body" });

    const dailyId = pickDailyId(body);
    if (dailyId != null && dailyId !== s.dailyChallengeId) {
      return res.status(404).json({ error: "DailyChallengeNotFound", message: "dailyChallengeId is not current", dailyChallengeId: dailyId });
    }

    const pid = pickPuzzleId(body);
    if (!pid) return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });

    const exists = s.puzzles.some(p => String(p.id) === pid);
    if (!exists) return res.status(404).json({ error: "PuzzleNotFound", message: "puzzleId not found in today's puzzles" });

    if (s.status === "completed") {
      return res.status(409).json({ error: "ChallengeCompleted", message: "daily challenge already completed" });
    }

    if (s.answered.has(pid)) {
      return res.status(409).json({ error: "PuzzleAlreadyAnswered", message: "puzzle already answered" });
    }
    s.answered.add(pid);

    const ans = pickAnswer(body);

    // For "shape-only" contract, missing answer is treated as valid (not 500)
    let correct;
    if (ans === undefined) correct = true;
    else {
      const expected = String(s.expected[pid] ?? "");
      correct = expected.toLowerCase().trim() === String(ans).toLowerCase().trim();
    }

    if (correct) s.solved.add(pid);
    s.progress = Math.min(s.puzzles.length, s.solved.size);

    if (s.progress >= s.puzzles.length) {
      s.status = "completed";
      streak = (Number(streak) || 0) + 1;
    } else if (s.status === "not_started") {
      s.status = "in_progress";
    }

    return res.status(200).json({ ok: Boolean(correct) });
  });

  return router;
}


function resetDailyChallengeState() {
  try {
    currentKey = null;
    state = null;
    streak = 0;
  } catch {}
}

module.exports = { createDailyChallengeRouter, resetDailyChallengeState };




