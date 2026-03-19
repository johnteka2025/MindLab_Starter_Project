"use strict";

function createPhase13ReleaseCheckpoint() {
  return {
    checkpoint(input = {}) {
      return {
        ok: true,
        phase: "phase13",
        checkpointed: true,
        input
      };
    }
  };
}

module.exports = { createPhase13ReleaseCheckpoint };
