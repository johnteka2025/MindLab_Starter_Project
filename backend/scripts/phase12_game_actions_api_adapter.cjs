"use strict";

function buildGameActionResponse(result = {}) {
  return {
    ok: true,
    type: "game-action",
    result
  };
}

module.exports = { buildGameActionResponse };
