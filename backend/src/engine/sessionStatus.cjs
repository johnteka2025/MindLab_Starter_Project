"use strict";

const { buildSessionController } = require("./sessionController.cjs");

function buildSessionStatus(input) {
  const controller = buildSessionController(input || {});

  return {
    player: controller.player,
    status: controller.status,
    sessionActive: controller.sessionActive,
    ready: controller.status === "ready"
  };
}

module.exports = {
  buildSessionStatus
};
