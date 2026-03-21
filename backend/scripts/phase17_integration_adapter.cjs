"use strict";

function createPhase17IntegrationAdapter() {
  return {
    connect(input = {}) {
      return {
        ok: true,
        phase: "phase17",
        connected: true,
        input
      };
    }
  };
}

module.exports = { createPhase17IntegrationAdapter };
