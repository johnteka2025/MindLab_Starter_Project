"use strict";

function buildMultiplayerMatch(input) {
    const payload = input || {};
    const matchId = payload.matchId || "match-local";
    const hostPlayer = payload.hostPlayer || "";
    const guestPlayer = payload.guestPlayer || "";
    const difficulty = payload.difficulty || "medium";
    const category = payload.category || "general";
    const questionCount = Number.isFinite(payload.questionCount) ? payload.questionCount : 10;
    const createdAt = new Date().toISOString();

    return {
        matchId,
        hostPlayer,
        guestPlayer,
        difficulty,
        category,
        questionCount,
        createdAt,
        state: "waiting_for_players",
        playersReady: hostPlayer !== "" && guestPlayer !== "",
        ok: true
    };
}

module.exports = { buildMultiplayerMatch };
