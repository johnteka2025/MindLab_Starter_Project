"use strict";

function createPhase18StateSnapshotManager() {
  return {
    takeSnapshot(state = {}) {
      return { ok: true, phase: "phase18", snapshot: JSON.parse(JSON.stringify(state)) };
    }
  };
}

module.exports = { createPhase18StateSnapshotManager };
