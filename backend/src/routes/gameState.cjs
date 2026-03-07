"use strict";

const express = require("express");
const { buildGameState } = require("../engine/gameState.cjs");

const router = express.Router();

router.post("/game-state", (req, res) => {
  const input = req.body || {};
  const result = buildGameState(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
