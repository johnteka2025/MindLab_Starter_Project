"use strict";

const payloads = [
    {
        name: "default_match",
        payload: {
            matchId: "match-001",
            hostPlayer: "Maya",
            guestPlayer: "Noah",
            difficulty: "medium",
            category: "general",
            questionCount: 10
        }
    },
    {
        name: "hard_science_match",
        payload: {
            matchId: "match-002",
            hostPlayer: "Ava",
            guestPlayer: "Leo",
            difficulty: "hard",
            category: "science",
            questionCount: 15
        }
    }
];

console.log(JSON.stringify(payloads, null, 2));
