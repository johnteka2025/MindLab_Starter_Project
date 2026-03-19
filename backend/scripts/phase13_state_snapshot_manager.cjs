"use strict";

function createPhase13StateSnapshotManager() {
  return {
    takeSnapshot(state = {}) {
      return {
        ok: true,
        phase: "phase13",
        snapshot: JSON.parse(JSON.stringify(state))
      };
    }
  };
}

module.exports = { createPhase13StateSnapshotManager };
