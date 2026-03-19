"use strict";

function formatPhase14Result(result = {}) {
  return {
    ok: true,
    phase: "phase14",
    formatted: result
  };
}

module.exports = { formatPhase14Result };
