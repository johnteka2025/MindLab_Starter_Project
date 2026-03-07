"use strict";

const express = require("express");
const { buildPlayerProfile } = require("../engine/playerProfile.cjs");

const router = express.Router();

router.post("/player-profile", (req, res) => {
  const player = req.body && req.body.player ? req.body.player : "";
  const attempts = req.body && Array.isArray(req.body.attempts) ? req.body.attempts : [];

  const result = buildPlayerProfile(player, attempts);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
