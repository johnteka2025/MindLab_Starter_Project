"use strict";

const express = require("express");
const { generateDailyPuzzle } = require("../engine/dailyPuzzle.cjs");
const { validateAnswer } = require("../engine/answerValidation.cjs");

const router = express.Router();

router.post("/validate", (req, res) => {
  const puzzle = generateDailyPuzzle();
  const submittedAnswer = req.body && req.body.answer ? req.body.answer : "";

  const result = validateAnswer(puzzle.answer, submittedAnswer);

  res.json({
    ok: result.ok,
    date: puzzle.date,
    question: puzzle.question,
    submitted: result.submitted
  });
});

module.exports = router;
