"use strict";

const adapter=require("./phase22_telemetry_adapter.cjs")

function assert(c,m){
if(!c){throw new Error(m)}
}

function main(){

const a=adapter.main({
sessionId:"s1",
matchId:"m1",
player:"Maya",
event:"join",
latencyMs:120,
scoreDelta:0
})

const b=adapter.main({
sessionId:"s2",
matchId:"m2",
player:"Noah",
event:"score",
latencyMs:400,
scoreDelta:200
})

assert(a.event==="join","event mismatch")
assert(b.scoreDelta===200,"score mismatch")

console.log("OK PHASE22 TELEMETRY VERIFY PASSED")

}

module.exports={main}

if(require.main===module){
main()
}
