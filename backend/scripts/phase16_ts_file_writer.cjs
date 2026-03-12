"use strict";

const fs = require("fs");
const path = require("path");

const outDir = path.join(__dirname, "..", "frontend-types");

function getScriptOutput(scriptPath) {
    delete require.cache[require.resolve(scriptPath)];
    const script = require(scriptPath);

    const chunks = [];
    const originalLog = console.log;

    console.log = (...args) => {
        chunks.push(args.join(" "));
    };

    try {
        if (typeof script.main === "function") {
            script.main();
        } else if (typeof script === "function") {
            script();
        } else {
            throw new Error("main export missing for " + scriptPath);
        }
    } finally {
        console.log = originalLog;
    }

    return chunks.join("\n").trim();
}

function writeFile(name, content) {
    fs.writeFileSync(path.join(outDir, name), content + "\n", "utf8");
}

function main() {
    if (fs.existsSync(outDir)) {
        fs.rmSync(outDir, { recursive: true, force: true });
    }

    fs.mkdirSync(outDir, { recursive: true });

    const contractsTs = getScriptOutput("./phase16_ts_contract_generator.cjs");
    const payloadsTs = getScriptOutput("./phase16_ts_payload_generator.cjs");
    const responsesTs = getScriptOutput("./phase16_ts_response_type_generator.cjs");

    writeFile("contracts.ts", contractsTs);
    writeFile("payloads.ts", payloadsTs);
    writeFile("responses.ts", responsesTs);

    console.log("OK PHASE16 TS FILE WRITER PASSED");
    console.log(outDir);
}

module.exports = { main };

if (require.main === module) {
    main();
}
