"use strict";

function getAiDecision(context = {}) {
  return {
    action: "wait",
    reason: "default-safe-decision",
    context
  };
}

module.exports = { getAiDecision };
