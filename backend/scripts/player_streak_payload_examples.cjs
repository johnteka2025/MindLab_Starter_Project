"use strict";

function buildExamples() {
  return {
    samplePayload: {
      attempts: [
        { date: "2026-03-01", ok: true },
        { date: "2026-03-02", ok: true },
        { date: "2026-03-03", ok: false },
        { date: "2026-03-04", ok: true },
        { date: "2026-03-05", ok: true },
        { date: "2026-03-06", ok: true }
      ]
    }
  };
}

if (require.main === module) {
  console.log(JSON.stringify(buildExamples(), null, 2));
}

module.exports = { buildExamples };
