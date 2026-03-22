const fs = require("fs");
const path = require("path");
const {
    runSmokeSuite,
    runRegressionSuite,
    runEdgeCaseSuite,
    getReport
} = require("./qa_automation_engine");

const reportPath = path.join(__dirname, "qa_report.json");
const backupPath = path.join(__dirname, "qa_report.test.backup.json");

function resetReport() {
    fs.writeFileSync(reportPath, JSON.stringify({
        runs: [],
        summary: {
            smokePass: 0,
            regressionPass: 0,
            edgeCasePass: 0
        }
    }, null, 2));
}

try {
    fs.copyFileSync(reportPath, backupPath);
    resetReport();

    runSmokeSuite();
    runRegressionSuite();
    runEdgeCaseSuite();

    const report = getReport();

    if (report.runs.length !== 3) throw new Error("STOP: expected three QA runs");
    if (report.summary.smokePass !== 1) throw new Error("STOP: smokePass mismatch");
    if (report.summary.regressionPass !== 1) throw new Error("STOP: regressionPass mismatch");
    if (report.summary.edgeCasePass !== 1) throw new Error("STOP: edgeCasePass mismatch");

    console.log("OK: QA automation test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, reportPath);
        fs.unlinkSync(backupPath);
    }
}
