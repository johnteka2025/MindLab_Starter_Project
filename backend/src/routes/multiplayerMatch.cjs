"use strict";

const express = require("express");
const { buildMultiplayerMatch } = require("../engine/multiplayerMatch.cjs");

const router = express.Router();

router.post("/multiplayer-match", (req, res) => {
    const input = req.body || {};
    const result = buildMultiplayerMatch(input);
    res.json({ ok: true, result });
});

module.exports = router;
