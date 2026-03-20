"use strict";

function createPhase14IntegrationAdapter() {
  return {
    connect(input = {}) {
      return {
        ok: true,
        phase: "phase14",
        connected: true,
        input
      };
    }
  };
}

module.exports = { createPhase14IntegrationAdapter };
