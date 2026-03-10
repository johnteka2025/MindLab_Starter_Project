"use strict";

const express=require("express");
const http=require("http");
const router=require("../src/routes/gameSession.cjs");

function assert(c,m){ if(!c){throw new Error(m);} }

function postJson(port,path,payload){

return new Promise((resolve,reject)=>{

const body=JSON.stringify(payload);

const req=http.request({

hostname:"127.0.0.1",
port,
path,
method:"POST",
headers:{
"Content-Type":"application/json",
"Content-Length":Buffer.byteLength(body)
}

},res=>{

let raw="";

res.on("data",c=>raw+=c);

res.on("end",()=>{

resolve({

statusCode:res.statusCode,
body:JSON.parse(raw)

});

});

});

req.on("error",reject);

req.write(body);
req.end();

});

}

async function main(){

const app=express();
app.use(express.json());
app.use("/game",router);

const server=app.listen(8120,"127.0.0.1");

try{

const r=await postJson(8120,"/game/game-session",{

player:"Maya",
difficulty:"medium",
question:"2+2?"

});

assert(r.statusCode===200,"expected 200");
assert(r.body.ok===true,"expected ok");
assert(r.body.result.player==="Maya","player mismatch");
assert(r.body.result.status==="active","status mismatch");

console.log("OK ROUTE GAME SESSION SMOKE PASSED");

}
finally{

await new Promise(resolve=>server.close(resolve));

}

}

main().catch(e=>{console.error(e);process.exit(1);});
