"use strict";

function generateDailyPuzzle() {
  const today = new Date().toISOString().slice(0, 10);

  const puzzles = [
    { id: "p1", question: "2+2", answer: "4", difficulty: "easy" },
    { id: "p2", question: "3+5", answer: "8", difficulty: "easy" },
    { id: "p3", question: "10-7", answer: "3", difficulty: "easy" }
  ];

  const seed = today.replace(/-/g, "").split("").reduce((a, b) => a + Number(b), 0);
  const index = Math.abs(seed) % puzzles.length;
  const chosen = puzzles[index];

  return {
    date: today,
    id: chosen.id,
    question: chosen.question,
    answer: chosen.answer,
    difficulty: chosen.difficulty
  };
}

module.exports = { generateDailyPuzzle };
