"use strict";

const express = require("express");
const { buildLeaderboardSnapshot } = require("../engine/leaderboardSnapshot.cjs");

const router = express.Router();

router.post("/leaderboard-snapshot", (req, res) => {
  const entries = req.body && Array.isArray(req.body.entries) ? req.body.entries : [];
  const snapshot = buildLeaderboardSnapshot(entries);

  res.json({
    ok: true,
    snapshot
  });
});

module.exports = router;
