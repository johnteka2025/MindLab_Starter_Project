const fs = require("fs");
const path = require("path");

const dataFile = path.join(__dirname, "tournament_data.json");

function loadData() {
    return JSON.parse(fs.readFileSync(dataFile, "utf8"));
}

function saveData(data) {
    fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
}

function createSession(sessionId) {
    const data = loadData();
    data.sessions.push({
        sessionId,
        entries: [],
        completed: false
    });
    saveData(data);
}

function recordScore(sessionId, player, score, win) {
    const data = loadData();
    const session = data.sessions.find(x => x.sessionId === sessionId);

    if (!session) {
        throw new Error("STOP: session not found");
    }

    session.entries.push({ player, score, win: !!win });

    const existing = data.leaderboard.find(x => x.player === player);
    if (existing) {
        existing.score += score;
        existing.wins += win ? 1 : 0;
    } else {
        data.leaderboard.push({
            player,
            score,
            wins: win ? 1 : 0
        });
    }

    data.leaderboard.sort((a, b) => {
        if (b.score !== a.score) return b.score - a.score;
        return b.wins - a.wins;
    });

    saveData(data);
}

function completeSession(sessionId) {
    const data = loadData();
    const session = data.sessions.find(x => x.sessionId === sessionId);

    if (!session) {
        throw new Error("STOP: session not found");
    }

    session.completed = true;
    saveData(data);
}

module.exports = {
    createSession,
    recordScore,
    completeSession
};
