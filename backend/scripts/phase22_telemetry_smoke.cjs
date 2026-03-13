"use strict";

const adapter=require("./phase22_telemetry_adapter.cjs")

function assert(c,m){
if(!c){throw new Error(m)}
}

function main(){

const r=adapter.main({
sessionId:"session-900",
matchId:"match-900",
player:"Maya",
event:"answer",
latencyMs:300,
scoreDelta:100
})

assert(r.ok===true,"ok mismatch")
assert(r.telemetryId==="telemetry-match-900","id mismatch")
assert(r.player==="Maya","player mismatch")
assert(r.event==="answer","event mismatch")

console.log("OK PHASE22 TELEMETRY SMOKE PASSED")

}

module.exports={main}

if(require.main===module){
main()
}
