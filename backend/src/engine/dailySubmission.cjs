"use strict";

const { generateDailyPuzzle } = require("./dailyPuzzle.cjs");
const { validateAnswer } = require("./answerValidation.cjs");
const { buildScoreResult } = require("./scoreEngine.cjs");

function submitDailyAnswer(submittedAnswer) {
  const puzzle = generateDailyPuzzle();
  const validation = validateAnswer(puzzle.answer, submittedAnswer);
  const score = buildScoreResult(validation.ok);

  return {
    date: puzzle.date,
    puzzleId: puzzle.id,
    question: puzzle.question,
    submitted: validation.submitted,
    ok: validation.ok,
    points: score.points
  };
}

module.exports = { submitDailyAnswer };
