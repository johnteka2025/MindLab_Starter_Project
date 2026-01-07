const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 8085;

app.use(cors());
app.use(express.json());

/**
 * Health endpoint (tests + sanity checks)
 */
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    uptime: process.uptime()
  });
});

/**
 * Puzzles endpoint
 * Returns an array of puzzles.
 * Tries known JSON locations; falls back to a minimal list.
 */
/* PHASE5: moved /puzzles to puzzlesRoutes.cjs (kept for rollback)
app.get("/puzzles", (req, res) => {
  try {
    const candidates = [
      path.join(__dirname, "index.json"),
      path.join(__dirname, "puzzles", "index.json"),
      path.join(__dirname, "puzzles", "index.json")
    ];

    let found = null;
    for (const p of candidates) {
      if (fs.existsSync(p)) { found = p; break; }
    }

    if (found) {
      const raw = fs.readFileSync(found, "utf8");
      const data = JSON.parse(raw);
      const puzzles = Array.isArray(data) ? data : (Array.isArray(data.puzzles) ? data.puzzles : []);
      return res.status(200).json(puzzles);
    }

    // Fallback minimal puzzles list
    return res.status(200).json([
      { id: "demo-1", question: "2 + 2 = ?", answer: "4" },
      { id: "demo-2", question: "Spell 'mind' backwards.", answer: "dnim" }
    ]);
  } catch (e) {
    return res.status(500).json({ error: "Failed to load puzzles", details: String(e) });
  }
});
*/

/**
 * Progress routes (real routing, shared store)
 */
const registerProgressRoutes = require("./progressRoutes.cjs");
const registerPuzzlesRoutes = require("./puzzlesRoutes.cjs");
const difficultyRoutes = require("./difficultyRoutes.cjs");
registerProgressRoutes(app);
app.use("/difficulty", difficultyRoutes);
registerPuzzlesRoutes(app);

// Enable JSON persistence for progress (Phase 4B)
const initProgressPersistence = require("./progressPersistence.cjs");
initProgressPersistence();

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;

