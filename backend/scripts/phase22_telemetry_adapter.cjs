"use strict";

function assertString(v,n){
if(typeof v!=="string"||v.trim()===""){throw new Error(n+" invalid")}
}

function assertNumber(v,n){
if(typeof v!=="number"){throw new Error(n+" invalid")}
}

function main(input){

const payload=input||{
sessionId:"session-900",
matchId:"match-900",
player:"Maya",
event:"answer",
latencyMs:300,
scoreDelta:100
}

assertString(payload.sessionId,"sessionId")
assertString(payload.matchId,"matchId")
assertString(payload.player,"player")
assertString(payload.event,"event")
assertNumber(payload.latencyMs,"latencyMs")
assertNumber(payload.scoreDelta,"scoreDelta")

const result={
ok:true,
telemetryId:"telemetry-"+payload.matchId,
sessionId:payload.sessionId,
matchId:payload.matchId,
player:payload.player,
event:payload.event,
latencyMs:payload.latencyMs,
scoreDelta:payload.scoreDelta,
capturedAt:new Date().toISOString()
}

console.log(JSON.stringify(result,null,2))
return result
}

module.exports={main}

if(require.main===module){
main()
}
