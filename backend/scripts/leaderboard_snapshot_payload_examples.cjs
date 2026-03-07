"use strict";

function buildExamples() {
  return {
    samplePayload: {
      entries: [
        { player: "Maya", points: 30 },
        { player: "Omar", points: 50 },
        { player: "Lina", points: 40 }
      ]
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
