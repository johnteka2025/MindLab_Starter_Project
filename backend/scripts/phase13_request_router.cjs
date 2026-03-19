"use strict";

function routePhase13Request(input = {}) {
  const route = input.route || "default";
  return {
    ok: true,
    phase: "phase13",
    route,
    payload: input.payload || {}
  };
}

module.exports = { routePhase13Request };
