const { buildWeeklyReport } = require("./cognitive_report_generator_v2");

try {
    const profile = {
        userId: "user-001",
        skills: {
            pattern_recognition: 2,
            working_memory: 1
        }
    };

    const sessions = [{}, {}, {}];

    const report = buildWeeklyReport(profile, sessions);

    if (report.summary.sessionsCompleted !== 3) {
        throw new Error("STOP: report session count mismatch");
    }

    console.log("OK: report generator test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
