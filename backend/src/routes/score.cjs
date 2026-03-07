"use strict";

const express = require("express");
const { buildScoreResult } = require("../engine/scoreEngine.cjs");

const router = express.Router();

router.post("/score", (req, res) => {
  const isCorrect = !!(req.body && req.body.isCorrect);
  const result = buildScoreResult(isCorrect);

  res.json({
    ok: result.ok,
    points: result.points
  });
});

module.exports = router;
