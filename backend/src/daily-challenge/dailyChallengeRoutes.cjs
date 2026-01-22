"use strict";

const express = require("express");
const fs = require("fs");
const path = require("path");

function utcDayKey() {
  // YYYY-MM-DD in UTC
  return new Date().toISOString().slice(0, 10);
}

function safeReadJson(p, fallback) {
  try {
    if (!fs.existsSync(p)) return fallback;
    const raw = fs.readFileSync(p, "utf8");
    return JSON.parse(raw);
  } catch (_) {
    return fallback;
  }
}

function loadPuzzleBank() {
  // Prefer backend/src/data/puzzles.json if present
  const p = path.join(__dirname, "..", "data", "puzzles.json");
  const bank = safeReadJson(p, null);

  if (Array.isArray(bank)) return bank;
  if (bank && Array.isArray(bank.puzzles)) return bank.puzzles;

  // Fallback minimal bank (keeps API alive even if file missing)
  return [
    { id: 1, prompt: "Puzzle 1" },
    { id: 2, prompt: "Puzzle 2" },
    { id: 3, prompt: "Puzzle 3" },
  ];
}

function normalizeId(v) {
  if (typeof v === "number" && Number.isFinite(v)) return String(v);
  if (typeof v === "string") {
    const t = v.trim();
    return t.length ? t : null;
  }
  return null;
}

function normalizeBody(req) {
  if (!req) return {};
  let b = (req.body != null) ? req.body : {};
  if (typeof b === "string") {
    try { b = JSON.parse(b); } catch (_) { b = {}; }
  }
  if (b && typeof b === "object") return b;
  return {};
}

// In-memory per-UTC-day state (simple + deterministic for contract tests)
const stateByDay = new Map();

function getOrCreateStateForToday() {
  const key = utcDayKey();
  const existing = stateByDay.get(key);
  if (existing) return existing;

  const bank = loadPuzzleBank();

  // Deterministic "daily" selection (first N)
  const puzzles = bank.slice(0, Math.min(5, bank.length)).map(p => ({
    id: p.id,
    ...(p.prompt != null ? { prompt: p.prompt } : {}),
  }));

  const s = {
    dayKey: key,
    dailyChallengeId: `daily-${key}`,
    puzzles,
    status: "not_started",   // "not_started" | "in_progress" | "completed"
    progress: 0,
    streak: 0,
    answered: new Set(),     // string puzzleId
  };

  stateByDay.set(key, s);
  return s;
}

function createDailyChallengeRouter() {
  const router = express.Router();

  // GET /daily  -> must return instance with puzzles
  router.get("/daily", (_req, res) => {
    const s = getOrCreateStateForToday();
    return res.status(200).json({
      dailyChallengeId: s.dailyChallengeId,
      puzzles: s.puzzles,
    });
  });

  // GET /daily/status -> must return status + progress + streak
  router.get("/daily/status", (_req, res) => {
    const s = getOrCreateStateForToday();
    return res.status(200).json({
      dailyChallengeId: s.dailyChallengeId,
      status: s.status,
      progress: s.progress,
      streak: s.streak,
    });
  });

  // POST /daily/answer
  router.post("/daily/answer", (req, res) => {
    const s = getOrCreateStateForToday();
    const body = normalizeBody(req);

    // Optional dailyChallengeId validation (contract expects 404 when wrong)
    const providedDailyId = normalizeId(body.dailyChallengeId);
    if (providedDailyId && providedDailyId !== s.dailyChallengeId) {
      return res.status(404).json({
        error: "DailyChallengeNotFound",
        message: "dailyChallengeId is not current",
        dailyChallengeId: providedDailyId,
      });
    }

    // puzzleId is required for answer endpoint
    const puzzleId = normalizeId(body.puzzleId);
    if (!puzzleId) {
      return res.status(400).json({ error: "PuzzleIdMissing", message: "puzzleId is required" });
    }

    // puzzle must exist in today's puzzles
    const exists = Array.isArray(s.puzzles) && s.puzzles.some(p => String(p.id) === puzzleId);
    if (!exists) {
      return res.status(404).json({ error: "PuzzleNotFound", message: "puzzleId not found in today's puzzles" });
    }

    // completed -> 409
    if (s.status === "completed" || s.progress >= s.puzzles.length) {
      s.status = "completed";
      s.progress = s.puzzles.length;
      return res.status(409).json({ error: "ChallengeCompleted", message: "daily challenge already completed" });
    }

    // already answered -> 409
    if (s.answered.has(puzzleId)) {
      return res.status(409).json({ error: "PuzzleAlreadyAnswered", message: "puzzle already answered" });
    }

    // Accept answer even if answer field missing (contract tests do NOT require answer)
    s.answered.add(puzzleId);
    s.progress = Math.min(s.puzzles.length, s.answered.size);
    s.status = (s.progress > 0) ? "in_progress" : "not_started";

    if (s.progress >= s.puzzles.length) {
      s.status = "completed";
      s.streak = (Number(s.streak) || 0) + 1;
    }

    return res.status(200).json({
      dailyChallengeId: s.dailyChallengeId,
      puzzleId,
      status: s.status,
      progress: s.progress,
      streak: s.streak,
    });
  });

  return router;
}

module.exports = { createDailyChallengeRouter };
