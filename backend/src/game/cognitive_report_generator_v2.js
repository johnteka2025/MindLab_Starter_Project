function buildWeeklyReport(profile, sessions) {
    if (!profile) throw new Error("STOP: profile missing");
    if (!Array.isArray(sessions)) throw new Error("STOP: sessions missing");

    return {
        version: "2.0",
        userId: profile.userId,
        period: {
            type: "weekly"
        },
        summary: {
            sessionsCompleted: sessions.length,
            recommendedFocus: [],
            skillChanges: profile.skills || {}
        }
    };
}

module.exports = { buildWeeklyReport };
