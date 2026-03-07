"use strict";

const express = require("express");
const { buildSessionController } = require("../engine/sessionController.cjs");

const router = express.Router();

router.post("/session-controller",(req,res)=>{

const input=req.body || {};
const result=buildSessionController(input);

res.json({
ok:true,
result
});

});

module.exports=router;
