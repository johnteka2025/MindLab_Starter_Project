"use strict";

const payloadBundle = require("./phase16_client_payload_bundle.cjs");

function main() {
    const lines = [];
    lines.push("export const apiPayloadExamples = {");

    for (const [key, value] of Object.entries(payloadBundle)) {
        const payloadText = JSON.stringify(value.payload, null, 2)
            .split("\n")
            .map((line) => "  " + line)
            .join("\n");

        lines.push(`  ${key}: ${payloadText.trimStart()},`);
    }

    lines.push("};");
    console.log(lines.join("\n"));
}

main();
