"use strict";

const payloads = [
    {
        name: "hard_recommendation",
        payload: {
            playerAccuracy: 90,
            responseTimeMs: 7000
        }
    },
    {
        name: "easy_recommendation",
        payload: {
            playerAccuracy: 45,
            responseTimeMs: 12000
        }
    },
    {
        name: "medium_recommendation",
        payload: {
            playerAccuracy: 70,
            responseTimeMs: 9000
        }
    }
];

console.log(JSON.stringify(payloads, null, 2));
