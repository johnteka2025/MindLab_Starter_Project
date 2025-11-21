import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import jwt from "jsonwebtoken";

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = process.env.PORT || 8085;
const JWT_SECRET = process.env.JWT_SECRET || "devsecret";

app.get("/api/health", (_req,res)=> res.json({ ok:true }));

app.post("/api/auth/login", (req,res)=>{
  const {username,password} = req.body || {};
  if(!username || !password) return res.status(400).json({error:"bad creds"});
  const token = jwt.sign({ sub: username }, JWT_SECRET, { expiresIn: "1h" });
  res.json({ token });
});

app.get("/api/puzzles/1", (req,res)=>{
  const m = (req.headers.authorization||"").match(/^Bearer (.+)$/);
  if(!m) return res.status(401).json({error:"missing token"});
  try { jwt.verify(m[1], JWT_SECRET); } catch { return res.status(401).json({error:"bad token"}); }
  res.json({ id:1, title:"Hello MindLab", difficulty:"easy" });
});

app.listen(PORT, ()=> console.log("API listening on", PORT));
