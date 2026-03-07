"use strict";

const express = require("express");
const { submitDailyAnswer } = require("../engine/dailySubmission.cjs");

const router = express.Router();

router.post("/submit", (req, res) => {
  const submittedAnswer = req.body && req.body.answer ? req.body.answer : "";
  const result = submitDailyAnswer(submittedAnswer);
  res.json(result);
});

module.exports = router;
