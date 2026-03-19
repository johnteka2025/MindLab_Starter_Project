"use strict";

function createPhase13RuntimeBridge() {
  return {
    bridge(payload = {}) {
      return {
        ok: true,
        phase: "phase13",
        bridged: true,
        payload
      };
    }
  };
}

module.exports = { createPhase13RuntimeBridge };
