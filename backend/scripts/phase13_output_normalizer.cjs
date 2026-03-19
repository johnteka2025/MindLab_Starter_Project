"use strict";

function normalizePhase13Output(result = {}) {
  return {
    ok: true,
    phase: "phase13",
    normalized: result
  };
}

module.exports = { normalizePhase13Output };
