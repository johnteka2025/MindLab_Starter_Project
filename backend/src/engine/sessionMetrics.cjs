"use strict";

const { buildSessionDigest } = require("./sessionDigest.cjs");

function buildSessionMetrics(input){

const digest = buildSessionDigest(input || {})

const attempts = input && Array.isArray(input.attempts)
? input.attempts
: []

const totalAttempts = attempts.filter(a=>a.player===digest.player).length

const avgPointsPerAttempt =
totalAttempts>0
? Number((digest.totalPoints/totalAttempts).toFixed(2))
: 0

return{
player:digest.player,
status:digest.status,
sessionActive:digest.sessionActive,
leaderboardRank:digest.leaderboardRank,
totalPoints:digest.totalPoints,
totalAttempts,
avgPointsPerAttempt
}

}

module.exports={buildSessionMetrics}
