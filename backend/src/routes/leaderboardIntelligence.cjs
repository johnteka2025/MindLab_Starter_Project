"use strict";

const express = require("express");
const { buildLeaderboardIntelligence } = require("../engine/leaderboardIntelligence.cjs");

const router = express.Router();

router.post("/leaderboard-intelligence", (req, res) => {
  const entries = req.body && Array.isArray(req.body.entries) ? req.body.entries : [];
  const result = buildLeaderboardIntelligence(entries);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
