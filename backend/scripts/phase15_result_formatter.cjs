"use strict";

function formatPhase15Result(result = {}) {
  return {
    ok: true,
    phase: "phase15",
    formatted: result
  };
}

module.exports = { formatPhase15Result };
