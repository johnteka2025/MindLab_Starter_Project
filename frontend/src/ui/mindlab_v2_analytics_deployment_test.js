const { loadAnalyticsDashboard } = require("./mindlab_v2_analytics_dashboard");
const { loadLearnerAnalyticsTrends } = require("./mindlab_v2_learner_analytics_trends");

try {
    const dashboard = loadAnalyticsDashboard({
        totalSessions: 15,
        totalLearners: 5,
        avgCompletionRate: 92,
        trends: [{ week: "W1", completionRate: 92 }]
    });

    if (!dashboard || dashboard.metrics.totalSessions !== 15) {
        throw new Error("STOP: analytics dashboard mismatch");
    }

    const trends = loadLearnerAnalyticsTrends({
        learnerId: "learner-001",
        weeklyTrend: [1, 2, 3],
        monthlyTrend: [4, 5, 6]
    });

    if (!trends || trends.learnerId !== "learner-001") {
        throw new Error("STOP: learner analytics trends mismatch");
    }

    console.log("OK: analytics/deployment test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}


