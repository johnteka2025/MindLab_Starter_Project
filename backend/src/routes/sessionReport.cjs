"use strict";

const express = require("express");
const { buildSessionReport } = require("../engine/sessionReport.cjs");

const router = express.Router();

router.post("/session-report", (req, res) => {
  const input = req.body || {};
  const result = buildSessionReport(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
