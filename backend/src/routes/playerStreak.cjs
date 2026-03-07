"use strict";

const express = require("express");
const { buildPlayerStreak } = require("../engine/playerStreak.cjs");

const router = express.Router();

router.post("/player-streak", (req, res) => {
  const attempts = req.body && Array.isArray(req.body.attempts) ? req.body.attempts : [];
  const result = buildPlayerStreak(attempts);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
