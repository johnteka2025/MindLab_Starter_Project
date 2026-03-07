"use strict";

function buildExamples() {
  return {
    correctPayload: {
      isCorrect: true
    },
    wrongPayload: {
      isCorrect: false
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
