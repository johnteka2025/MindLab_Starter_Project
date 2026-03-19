"use strict";

function createPhase13CompletionCoordinator() {
  return {
    finalize(payload = {}) {
      return {
        ok: true,
        phase: "phase13",
        finalized: true,
        payload
      };
    }
  };
}

module.exports = { createPhase13CompletionCoordinator };
