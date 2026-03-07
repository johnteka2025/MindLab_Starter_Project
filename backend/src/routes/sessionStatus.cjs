"use strict";

const express = require("express");
const { buildSessionStatus } = require("../engine/sessionStatus.cjs");

const router = express.Router();

router.post("/session-status", (req, res) => {
  const input = req.body || {};
  const result = buildSessionStatus(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
