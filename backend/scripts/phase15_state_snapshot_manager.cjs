"use strict";

function createPhase15StateSnapshotManager() {
  return {
    takeSnapshot(state = {}) {
      return {
        ok: true,
        phase: "phase15",
        snapshot: JSON.parse(JSON.stringify(state))
      };
    }
  };
}

module.exports = { createPhase15StateSnapshotManager };
