"use strict";

const express = require("express");
const { buildSessionOverview } = require("../engine/sessionOverview.cjs");

const router = express.Router();

router.post("/session-overview", (req, res) => {
  const input = req.body || {};
  const result = buildSessionOverview(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
