"use strict";

function buildExamples() {
  return {
    samplePayload: {
      player: "Maya",
      attempts: [],
      scoreboardEntries: [
        { player: "Omar", points: 50 },
        { player: "Maya", points: 20 }
      ]
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
