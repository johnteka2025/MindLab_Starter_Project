const express = require("express");
const path = require("path");
const fs = require("fs");

const router = express.Router();

router.get("/", (req, res) => {
  const dataPath = path.join(__dirname, "data", "puzzleDifficulty.json");

  try {
    if (!fs.existsSync(dataPath)) {
      return res.status(500).json({ error: "Difficulty data missing", dataPath });
    }

    const raw = fs.readFileSync(dataPath, "utf8");
    const data = JSON.parse(raw);
    return res.json(data);
  } catch (err) {
    return res.status(500).json({
      error: "Difficulty JSON parse failed",
      dataPath,
      message: err && err.message ? err.message : String(err),
    });
  }
});

module.exports = router;
