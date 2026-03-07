"use strict";

const express = require("express");
const { buildScoreboard } = require("../engine/scoreboard.cjs");

const router = express.Router();

router.post("/scoreboard", (req, res) => {
  const entries = req.body && Array.isArray(req.body.entries) ? req.body.entries : [];
  const scoreboard = buildScoreboard(entries);

  res.json({
    ok: true,
    count: scoreboard.length,
    scoreboard
  });
});

module.exports = router;
