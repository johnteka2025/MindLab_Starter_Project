"use strict";

const express = require("express");
const { buildSessionSummary } = require("../engine/sessionSummary.cjs");

const router = express.Router();

router.post("/session-summary", (req, res) => {
  const input = req.body || {};
  const result = buildSessionSummary(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
