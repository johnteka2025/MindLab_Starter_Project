const fs = require("fs");
const path = require("path");

function readJsonSafe(p) {
  const raw = fs.readFileSync(p, "utf8");
  return JSON.parse(raw);
}

function normalizeDifficulty(s) {
  return String(s || "all").trim().toLowerCase();
}

function loadDifficultyMap() {
  const diffPath = path.join(__dirname, "data", "puzzleDifficulty.json");
  if (!fs.existsSync(diffPath)) {
    return { ok: false, diffPath };
  }
  const diff = readJsonSafe(diffPath);
  const levels = Array.isArray(diff.levels) ? diff.levels.map(x => String(x).toLowerCase()) : ["easy","medium","hard"];
  const map = diff.map && typeof diff.map === "object" ? diff.map : {};
  const def = String(diff.default || "medium").toLowerCase();
  return { ok: true, diffPath, levels, map, def };
}

function registerPuzzlesRoutes(app) {
  app.get("/puzzles", (req, res) => {
    try {
      const requested = normalizeDifficulty(req.query.difficulty);
      const wantAll = requested === "all" || requested === "" || requested == null;

      // Load puzzles (same as prior behavior)
      const candidates = [
        path.join(__dirname, "index.json"),
        path.join(__dirname, "puzzles", "index.json"),
      ];

      let found = null;
      for (const p of candidates) {
        if (fs.existsSync(p)) { found = p; break; }
      }

      let puzzles = [];
      if (found) {
        const data = readJsonSafe(found);
        puzzles = Array.isArray(data) ? data : (Array.isArray(data.puzzles) ? data.puzzles : []);
      } else {
        puzzles = [
          { id: 1, question: "What is 2 + 2?", options: ["3","4","5"], correctIndex: 1 },
          { id: 2, question: "What is the color of the sky?", options: ["Blue","Green","Red"], correctIndex: 0 },
        ];
      }

      // Load difficulty mapping (for enrichment and optional filtering)
      const dm = loadDifficultyMap();
      if (!dm.ok) {
        return res.status(500).json({ error: "Difficulty data missing", diffPath: dm.diffPath });
      }

      // Validate requested difficulty (if filtering)
      if (!wantAll && !dm.levels.includes(requested)) {
        return res.status(400).json({ error: "Invalid difficulty", allowed: ["all", ...dm.levels], requested });
      }

      // Enrich each puzzle with difficulty
      const enriched = puzzles.map(p => {
        const key = String(p.id);
        const d = String(dm.map[key] || dm.def).toLowerCase();
        return { ...p, difficulty: d };
      });

      // Filter if requested
      const out = wantAll ? enriched : enriched.filter(p => p.difficulty === requested);

      return res.status(200).json(out);
    } catch (e) {
      return res.status(500).json({ error: "Failed to load puzzles", details: String(e) });
    }
  });
}

module.exports = registerPuzzlesRoutes;