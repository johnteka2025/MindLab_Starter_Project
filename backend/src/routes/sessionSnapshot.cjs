"use strict";

const express = require("express");
const { buildSessionSnapshot } = require("../engine/sessionSnapshot.cjs");

const router = express.Router();

router.post("/session-snapshot", (req, res) => {
  const input = req.body || {};
  const result = buildSessionSnapshot(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
