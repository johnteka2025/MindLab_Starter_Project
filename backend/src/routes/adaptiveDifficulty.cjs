"use strict";

const express = require("express");
const { buildAdaptiveDifficulty } = require("../engine/adaptiveDifficulty.cjs");

const router = express.Router();

router.post("/adaptive-difficulty", (req, res) => {
  const input = req.body || {};
  const result = buildAdaptiveDifficulty(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
