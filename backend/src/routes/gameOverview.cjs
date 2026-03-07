"use strict";

const express = require("express");
const { buildGameOverview } = require("../engine/gameOverview.cjs");

const router = express.Router();

router.post("/game-overview", (req, res) => {
  const scoreboardEntries = req.body && Array.isArray(req.body.scoreboardEntries) ? req.body.scoreboardEntries : [];
  const result = buildGameOverview(scoreboardEntries);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
