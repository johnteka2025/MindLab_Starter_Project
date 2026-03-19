"use strict";

function createPhase13IntegrationAdapter() {
  return {
    connect(input = {}) {
      return {
        ok: true,
        phase: "phase13",
        connected: true,
        input
      };
    }
  };
}

module.exports = { createPhase13IntegrationAdapter };
