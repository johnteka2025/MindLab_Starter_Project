"use strict";

function createPhase17StateSnapshotManager() {
  return {
    takeSnapshot(state = {}) {
      return {
        ok: true,
        phase: "phase17",
        snapshot: JSON.parse(JSON.stringify(state))
      };
    }
  };
}

module.exports = { createPhase17StateSnapshotManager };
