"use strict";

function buildExamples() {
  return {
    samplePayload: {
      player: "Maya",
      attempts: [
        { player: "Maya", date: "2026-03-01", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-02", ok: true, points: 10 },
        { player: "Maya", date: "2026-03-03", ok: false, points: 0 },
        { player: "Maya", date: "2026-03-04", ok: true, points: 10 },
        { player: "Omar", date: "2026-03-01", ok: true, points: 10 }
      ]
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
