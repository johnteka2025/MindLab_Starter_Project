"use strict";

function formatPhase16Result(result = {}) {
  return {
    ok: true,
    phase: "phase16",
    formatted: result
  };
}

module.exports = { formatPhase16Result };
