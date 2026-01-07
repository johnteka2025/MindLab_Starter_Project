require("dotenv").config();
const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

const API_PORT = process.env.API_PORT || 8085;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// async wrapper for cleaner error flow
const wrap = fn => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

// robust health: 200 if db ok, otherwise 503
app.get("/health", wrap(async (req, res) => {
  let db = false;
  try {
    const r = await pool.query("SELECT 1 AS ok");
    db = r?.rows?.[0]?.ok === 1;
  } catch {}
  const ok = !!db;
  res.status(ok ? 200 : 503).json({ ok, db });
}));

// global error handler (no stack sent to client)
app.use((err, req, res, _next) => {
  console.error("[error]", err?.stack || err);
  res.status(500).json({ ok:false, error:"server_error" });
});

app.listen(API_PORT, () => {
  console.log(`MindLab API listening on ${API_PORT}`);
});
// ---------------------------------------------------------------------------
// Simple in-memory puzzle data for /api/puzzles
// ---------------------------------------------------------------------------
const PUZZLES = [
  {
    id: "intro-1",
    question: "What is 2 + 2?",
    options: ["1", "2", "4", "5"],
    correctIndex: 2,
    difficulty: "easy"
  },
  {
    id: "intro-2",
    question: "Which shape has 3 sides?",
    options: ["Square", "Triangle", "Circle"],
    correctIndex: 1,
    difficulty: "easy"
  }
];

// New API: GET /api/puzzles
app.get("/api/puzzles", (req, res) => {
  res.json({ puzzles: PUZZLES });
});
