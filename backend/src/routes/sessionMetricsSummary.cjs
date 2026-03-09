"use strict";

const express = require("express");
const { buildSessionMetricsSummary } = require("../engine/sessionMetricsSummary.cjs");

const router = express.Router();

router.post("/session-metrics-summary", (req, res) => {
  const input = req.body || {};
  const result = buildSessionMetricsSummary(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
