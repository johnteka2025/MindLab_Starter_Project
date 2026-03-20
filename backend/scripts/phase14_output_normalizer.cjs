"use strict";

function normalizePhase14Output(result = {}) {
  return {
    ok: true,
    phase: "phase14",
    normalized: result
  };
}

module.exports = { normalizePhase14Output };
