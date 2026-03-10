"use strict";

const express = require("express");
const { calibrateDifficulty } = require("../engine/aiDifficultyCalibration.cjs");

const router = express.Router();

router.post("/ai-difficulty-calibration", (req, res) => {
    const input = req.body || {};
    const result = calibrateDifficulty(input);
    res.json({ ok: true, result });
});

module.exports = router;
