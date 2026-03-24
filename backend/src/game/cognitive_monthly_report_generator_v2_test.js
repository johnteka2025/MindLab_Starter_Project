const { buildMonthlyReport } = require("./cognitive_monthly_report_generator_v2");

try {
    const profile = {
        userId: "user-001",
        skills: {
            pattern_recognition: 3,
            working_memory: 2,
            logical_reasoning: 1,
            cognitive_flexibility: 1
        }
    };

    const sessions = [{}, {}, {}, {}];
    const report = buildMonthlyReport(profile, sessions);

    if (report.summary.sessionsCompleted !== 4) {
        throw new Error("STOP: monthly report session count mismatch");
    }

    console.log("OK: monthly report generator test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
