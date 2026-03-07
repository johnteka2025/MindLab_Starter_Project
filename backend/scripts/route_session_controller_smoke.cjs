"use strict";

const http=require("http");
const express=require("express");
const router=require("../src/routes/sessionController.cjs");

function assert(c,m){ if(!c){ throw new Error(m); } }

function post(port,path,payload){

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

const server=app.listen(8105,"127.0.0.1");

try{

const result=await post(8105,"/game/session-controller",{
player:"Maya",
attempts:[],
scoreboardEntries:[
{player:"Omar",points:50},
{player:"Maya",points:20}
]
});

assert(result.statusCode===200,"expected 200");
assert(result.body.ok===true,"expected ok true");
assert(result.body.result.sessionActive===true,"expected active");

console.log("OK ROUTE SESSION CONTROLLER SMOKE PASSED");

}
finally{
await new Promise(r=>server.close(r));
}

}

main().catch(err=>{
console.error(err);
process.exit(1);
});
