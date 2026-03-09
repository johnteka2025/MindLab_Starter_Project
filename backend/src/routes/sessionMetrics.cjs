"use strict";

const express=require("express")
const{buildSessionMetrics}=require("../engine/sessionMetrics.cjs")

const router=express.Router()

router.post("/session-metrics",(req,res)=>{

const result=buildSessionMetrics(req.body||{})

res.json({
ok:true,
result
})

})

module.exports=router
