"use strict";

const express=require("express")
const http=require("http")
const router=require("../src/routes/sessionMetrics.cjs")

function assert(c,m){if(!c)throw new Error(m)}

function post(port,path,data){

return new Promise((resolve,reject)=>{

const body=JSON.stringify(data)

const req=http.request({
hostname:"127.0.0.1",
port,
path,
method:"POST",
headers:{
"Content-Type":"application/json",
"Content-Length":Buffer.byteLength(body)
}
},
res=>{
let raw=""
res.on("data",c=>raw+=c)
res.on("end",()=>resolve({status:res.statusCode,body:JSON.parse(raw)}))
})

req.on("error",reject)
req.write(body)
req.end()

})
}

async function main(){

const app=express()
app.use(express.json())
app.use("/game",router)

const server=app.listen(8120)

try{

const r=await post(8120,"/game/session-metrics",{
player:"Maya",
attempts:[
{player:"Maya",points:10},
{player:"Maya",points:0}
],
scoreboardEntries:[
{player:"Omar",points:50},
{player:"Maya",points:10}
]
})

assert(r.status===200,"expected 200")
assert(r.body.ok===true,"expected ok")
assert(r.body.result.player==="Maya","player")
assert(r.body.result.totalAttempts===2,"attempts")

console.log("OK SESSION METRICS SMOKE PASSED")

}
finally{
server.close()
}

}

main().catch(e=>{
console.error(e)
process.exit(1)
})
