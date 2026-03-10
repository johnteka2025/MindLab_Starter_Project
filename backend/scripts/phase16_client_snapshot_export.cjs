"use strict";

const contracts = require("./client_integration_contracts.cjs");
const payloadBundle = require("./phase16_client_payload_bundle.cjs");

const snapshot = {
    generatedAt: new Date().toISOString(),
    contracts,
    payloadBundle
};

module.exports = snapshot;

if (require.main === module) {
    console.log(JSON.stringify(snapshot, null, 2));
}
