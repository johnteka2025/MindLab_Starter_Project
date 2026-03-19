"use strict";

function formatPhase13Result(result = {}) {
  return {
    ok: true,
    phase: "phase13",
    formatted: result
  };
}

module.exports = { formatPhase13Result };
