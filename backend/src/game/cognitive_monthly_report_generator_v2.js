function buildMonthlyReport(profile, sessions) {
    if (!profile) throw new Error("STOP: profile missing");
    if (!Array.isArray(sessions)) throw new Error("STOP: sessions missing");

    return {
        version: "2.0",
        userId: profile.userId,
        period: {
            type: "monthly"
        },
        summary: {
            sessionsCompleted: sessions.length,
            topGrowthAreas: [],
            recommendedFocus: [],
            skillChanges: profile.skills || {}
        }
    };
}

module.exports = { buildMonthlyReport };
