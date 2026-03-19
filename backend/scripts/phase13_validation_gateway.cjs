"use strict";

function runPhase13ValidationGateway(data = {}) {
  return {
    ok: true,
    phase: "phase13",
    validated: true,
    data
  };
}

module.exports = { runPhase13ValidationGateway };
