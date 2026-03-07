"use strict";

const { buildSessionStatus } = require("./sessionStatus.cjs");
const { buildSessionSnapshot } = require("./sessionSnapshot.cjs");

function buildSessionOverview(input) {
  const status = buildSessionStatus(input || {});
  const snapshot = buildSessionSnapshot(input || {});

  return {
    player: status.player,
    status: status.status,
    ready: status.ready,
    sessionActive: status.sessionActive,
    snapshot
  };
}

module.exports = {
  buildSessionOverview
};
