"use strict";

const express=require("express");
const {buildGameSession}=require("../engine/gameSession.cjs");

const router=express.Router();

router.post("/game-session",(req,res)=>{

const input=req.body || {};
const result=buildGameSession(input);

res.json({ok:true,result});

});

module.exports=router;
