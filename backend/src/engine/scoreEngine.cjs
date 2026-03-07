"use strict";

function buildScoreResult(isCorrect) {
  return {
    ok: !!isCorrect,
    points: isCorrect ? 10 : 0
  };
}

module.exports = { buildScoreResult };
