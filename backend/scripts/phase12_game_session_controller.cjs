"use strict";

function createGameSessionController() {
  return {
    startSession(payload = {}) {
      return {
        ok: true,
        action: "startSession",
        payload
      };
    },
    stopSession(payload = {}) {
      return {
        ok: true,
        action: "stopSession",
        payload
      };
    }
  };
}

module.exports = { createGameSessionController };
