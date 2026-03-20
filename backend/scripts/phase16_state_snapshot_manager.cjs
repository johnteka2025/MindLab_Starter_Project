"use strict";

function createPhase16StateSnapshotManager() {
  return {
    takeSnapshot(state = {}) {
      return {
        ok: true,
        phase: "phase16",
        snapshot: JSON.parse(JSON.stringify(state))
      };
    }
  };
}

module.exports = { createPhase16StateSnapshotManager };
