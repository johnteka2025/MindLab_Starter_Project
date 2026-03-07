"use strict";

const express = require("express");
const { buildPlayerHistory } = require("../engine/playerHistory.cjs");

const router = express.Router();

router.post("/player-history", (req, res) => {
  const player = req.body && req.body.player ? req.body.player : "";
  const attempts = req.body && Array.isArray(req.body.attempts) ? req.body.attempts : [];

  const result = buildPlayerHistory(player, attempts);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
