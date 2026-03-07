"use strict";

const express = require("express");
const { buildPlayerDashboard } = require("../engine/playerDashboard.cjs");

const router = express.Router();

router.post("/player-dashboard", (req, res) => {
  const player = req.body && req.body.player ? req.body.player : "";
  const attempts = req.body && Array.isArray(req.body.attempts) ? req.body.attempts : [];
  const scoreboardEntries = req.body && Array.isArray(req.body.scoreboardEntries) ? req.body.scoreboardEntries : [];

  const result = buildPlayerDashboard(player, attempts, scoreboardEntries);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
