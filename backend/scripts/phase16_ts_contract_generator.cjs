"use strict";

const contracts = require("./client_integration_contracts.cjs");

function main() {
    const lines = [];
    lines.push('export type ApiContract = { endpoint: string; method: "POST" };');
    lines.push("");
    lines.push("export const apiContracts: Record<string, ApiContract> = {");

    for (const [key, value] of Object.entries(contracts)) {
        lines.push(`  ${key}: { endpoint: "${value.endpoint}", method: "POST" },`);
    }

    lines.push("};");
    console.log(lines.join("\n"));
}

main();
