const fs = require("fs");
const path = require("path");
const { createSession, recordScore, completeSession } = require("./tournament_engine");

const dataPath = path.join(__dirname, "tournament_data.json");
const backupPath = path.join(__dirname, "tournament_data.test.backup.json");

function resetData() {
    fs.writeFileSync(dataPath, JSON.stringify({ sessions: [], leaderboard: [] }, null, 2));
}

try {
    fs.copyFileSync(dataPath, backupPath);
    resetData();

    createSession("session-001");
    recordScore("session-001", "alice", 50, true);
    recordScore("session-001", "bob", 20, false);
    recordScore("session-001", "alice", 10, false);
    completeSession("session-001");

    const data = JSON.parse(fs.readFileSync(dataPath, "utf8"));

    if (data.sessions.length !== 1) {
        throw new Error("STOP: expected one session");
    }

    if (data.sessions[0].completed !== true) {
        throw new Error("STOP: session not completed");
    }

    if (data.leaderboard.length !== 2) {
        throw new Error("STOP: expected two leaderboard entries");
    }

    if (data.leaderboard[0].player !== "alice") {
        throw new Error("STOP: expected alice at top of leaderboard");
    }

    console.log("OK: tournament test passed");
}
catch (err) {
    console.error(err.message || err);
    process.exit(1);
}
finally {
    if (fs.existsSync(backupPath)) {
        fs.copyFileSync(backupPath, dataPath);
        fs.unlinkSync(backupPath);
    }
}
