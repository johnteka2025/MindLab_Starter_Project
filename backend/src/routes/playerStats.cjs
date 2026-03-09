"use strict";

const express = require("express");
const { buildPlayerStats } = require("../engine/playerStats.cjs");

const router = express.Router();

router.post("/player-stats", (req, res) => {
  const input = req.body || {};
  const result = buildPlayerStats(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
