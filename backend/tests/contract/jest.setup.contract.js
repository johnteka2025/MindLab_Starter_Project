"use strict";
const { resetServerState } = require("./_reset.contract.helper");
beforeEach(async () => {
  console.log("[contract-setup] reset");
  await resetServerState();
});
