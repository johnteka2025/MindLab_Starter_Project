const { loadAdminDashboard } = require("./mindlab_v2_admin_dashboard");
const { loadExportScreen } = require("./mindlab_v2_export_screen");

try {
    const admin = loadAdminDashboard({ users: [1], sessions: [1] });
    if (!admin || admin.users.length !== 1) {
        throw new Error("STOP: admin test failed");
    }

    const exportScreen = loadExportScreen({ data: "ok" });
    if (!exportScreen || exportScreen.screen !== "export") {
        throw new Error("STOP: export test failed");
    }

    console.log("OK: admin/export test passed");
}
catch (err) {
    console.error(err.message);
    process.exit(1);
}


