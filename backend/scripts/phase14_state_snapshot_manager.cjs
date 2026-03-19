"use strict";

function createPhase14StateSnapshotManager() {
  return {
    takeSnapshot(state = {}) {
      return {
        ok: true,
        phase: "phase14",
        snapshot: JSON.parse(JSON.stringify(state))
      };
    }
  };
}

module.exports = { createPhase14StateSnapshotManager };
