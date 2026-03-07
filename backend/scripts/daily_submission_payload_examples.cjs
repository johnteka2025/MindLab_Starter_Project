"use strict";

const { generateDailyPuzzle } = require("../src/engine/dailyPuzzle.cjs");

function buildExamples() {
  const puzzle = generateDailyPuzzle();

  return {
    correctPayload: {
      answer: puzzle.answer
    },
    wrongPayload: {
      answer: "wrong-answer"
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
