"use strict";

function buildExamples() {
  return {
    samplePayload: {
      totalCorrect: 5,
      bestStreak: 3,
      totalPoints: 60
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
