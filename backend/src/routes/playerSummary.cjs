"use strict";

const express = require("express");
const { buildPlayerSummary } = require("../engine/playerSummary.cjs");

const router = express.Router();

router.post("/player-summary", (req, res) => {
  const player = req.body && req.body.player ? req.body.player : "";
  const attempts = req.body && Array.isArray(req.body.attempts) ? req.body.attempts : [];

  const result = buildPlayerSummary(player, attempts);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
