"use strict";

function normalizePhase17Output(result = {}) {
  return {
    ok: true,
    phase: "phase17",
    normalized: result
  };
}

module.exports = { normalizePhase17Output };
