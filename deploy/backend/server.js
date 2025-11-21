const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
const PORT = process.env.PORT || 8085;
const ORIGIN = process.env.CORS_ORIGIN || "http://localhost";

const pool = new Pool({
  host: process.env.PGHOST,
  port: process.env.PGPORT,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
});

app.use(cors({ origin: ORIGIN }));
app.use(express.json());

app.get("/health", (_req, res) => res.json({ ok: true }));

app.get("/db/health", async (_req, res) => {
  try {
    const r = await pool.query("select version()");
    res.json({ ok: true, version: r.rows[0].version });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

app.post("/auth/login", (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) return res.status(400).json({ error: "missing credentials" });
  return res.json({ token: "devtoken" });
});

function requireAuth(req, res, next) {
  const hdr = req.header("authorization") || "";
  const token = hdr.startsWith("Bearer ") ? hdr.slice(7) : "";
  if (token !== "devtoken") return res.status(401).json({ error: "unauthorized" });
  next();
}

app.get("/puzzles/:id", requireAuth, async (req, res) => {
  const id = req.params.id;
  try {
    const q = await pool.query(
      "select id::text, title, prompt, difficulty from puzzles where id=$1",
      [id]
    );
    if (q.rows.length === 0) return res.status(404).json({ error: "not found" });
    res.json(q.rows[0]);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get("/boom", (_req, res) => res.status(500).json({ error: "boom" }));

app.listen(PORT, "0.0.0.0", () => {
  console.log("api listening on", PORT);
});
