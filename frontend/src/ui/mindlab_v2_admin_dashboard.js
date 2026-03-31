function loadAdminDashboard(data) {
    if (!data) throw new Error("STOP: admin data missing");

    return {
        screen: "admin-dashboard",
        state: "ready",
        users: data.users || [],
        sessions: data.sessions || []
    };
}

module.exports = { loadAdminDashboard };

