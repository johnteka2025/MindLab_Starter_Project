"use strict";

function normalizePhase16Output(result = {}) {
  return {
    ok: true,
    phase: "phase16",
    normalized: result
  };
}

module.exports = { normalizePhase16Output };
