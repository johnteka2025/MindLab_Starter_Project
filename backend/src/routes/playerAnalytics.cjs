"use strict";

const express = require("express");
const { buildPlayerAnalytics } = require("../engine/playerAnalytics.cjs");

const router = express.Router();

router.post("/player-analytics", (req, res) => {
  const input = req.body || {};
  const result = buildPlayerAnalytics(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
