"use strict";

const express = require("express");
const { buildSessionDigest } = require("../engine/sessionDigest.cjs");

const router = express.Router();

router.post("/session-digest", (req, res) => {
  const input = req.body || {};
  const result = buildSessionDigest(input);

  res.json({
    ok: true,
    result
  });
});

module.exports = router;
