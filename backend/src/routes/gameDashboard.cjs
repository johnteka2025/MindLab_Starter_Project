"use strict";

const express = require("express");
const { buildGameDashboard } = require("../engine/gameDashboard.cjs");

const router = express.Router();

router.post("/game-dashboard", (req, res) => {
  const input = req.body || {};
  const result = buildGameDashboard(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
