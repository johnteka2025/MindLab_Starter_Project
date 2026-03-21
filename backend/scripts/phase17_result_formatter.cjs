"use strict";

function formatPhase17Result(result = {}) {
  return {
    ok: true,
    phase: "phase17",
    formatted: result
  };
}

module.exports = { formatPhase17Result };
