"use strict";

const express = require("express");
const { buildPlayerAchievement } = require("../engine/playerAchievement.cjs");

const router = express.Router();

router.post("/player-achievement", (req, res) => {
  const input = req.body || {};
  const result = buildPlayerAchievement(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
