"use strict";

const { generateDailyPuzzle } = require("../src/engine/dailyPuzzle.cjs");
const { validateAnswer } = require("../src/engine/answerValidation.cjs");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function main() {
  const puzzle = generateDailyPuzzle();

  assert(puzzle, "puzzle not returned");
  assert(typeof puzzle.date === "string" && puzzle.date.length === 10, "invalid puzzle date");
  assert(typeof puzzle.question === "string" && puzzle.question.length > 0, "invalid puzzle question");
  assert(typeof puzzle.answer === "string" && puzzle.answer.length > 0, "invalid puzzle answer");

  const good = validateAnswer(puzzle.answer, puzzle.answer);
  const bad = validateAnswer(puzzle.answer, "wrong-answer");

  assert(good.ok === true, "expected correct answer validation to pass");
  assert(bad.ok === false, "expected wrong answer validation to fail");

  console.log("OK ENGINE SMOKE PASSED");
}

main();
