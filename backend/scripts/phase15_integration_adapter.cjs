"use strict";

function createPhase15IntegrationAdapter() {
  return {
    connect(input = {}) {
      return {
        ok: true,
        phase: "phase15",
        connected: true,
        input
      };
    }
  };
}

module.exports = { createPhase15IntegrationAdapter };
